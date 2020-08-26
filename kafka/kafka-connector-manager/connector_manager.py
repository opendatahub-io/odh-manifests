#! /usr/bin/env python3

import argparse
import copy
import json
import logging
import os
import requests


CONFIG_DIR = '/etc/dh-kafka-connectors.d/'

logger = logging.getLogger(__name__)
handler = logging.StreamHandler()
formatter = logging.Formatter(
        '%(asctime)s %(name)-12s %(levelname)-8s %(message)s')
handler.setFormatter(formatter)
logger.addHandler(handler)
logger.setLevel(logging.INFO)


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('-e', '--endpoint', dest='connect_endpoint',
                        help='The Kafka connect API endpoint',
                        required=True)
    parser.add_argument('-c', '--config-dir', dest='config_dir',
                        help=('The directory where connector configs '
                              'are stored'),
                        default=CONFIG_DIR)
    parser.add_argument('-o', '--overwrite', dest='overwrite_config',
                        default=False, action='store_true',
                        help='Overwrite existing connector configs')

    return parser.parse_args()


def get_configs(config_dir):
    configs = []
    if not os.path.exists(config_dir):
        raise Exception(f'Config directory {config_dir} does not exist')
    for f_name in os.listdir(config_dir):
        if f_name.endswith('.json'):
            with open(os.path.join(config_dir, f_name)) as f:
                configs.append(json.loads(f.read()))

    return configs


def validate_config(config):
    required_keys = ['name', 'config']
    for key in required_keys:
        if key not in config:
            raise Exception(f'Required key "{key}" is missing from the config')
    required_config_keys = []
    for key in required_config_keys:
        if key not in config['config']:
            raise Exception(f'Required key "{key}" is missing from connector.config')


def connector_exists(connect_endpoint, connector_name):
    url = f'{connect_endpoint}/connectors'
    r = requests.get(url)
    connectors = r.json()
    return connector_name in connectors


def get_current_config(connect_endpoint, name):
    url = f'{connect_endpoint}/connectors/{name}'
    return requests.get(url).json()


# Returns true if dictionaries are different, false otherwise
# Recurses through multiple levels of nested dicts
def _dict_diff(name, first, second):
    ignored_keys = ['tasks', 'type', 'name']
    for key, value in first.items():
        if key not in ignored_keys:
            if key not in second.keys():
                logger.info((f'For the connector named "{name}", the running '
                             f'config has a key named "{key}", but the target '
                             f'config does not.'))
                return True
            elif isinstance(value, dict) and isinstance(second[key], dict):
                # The value is a dictionary, so we need to recurse into it to diff
                # the contents
                return _dict_diff(name, value, second[key])
            elif value != second[key]:
                logger.info((f'For the connector named "{name}", the running '
                             f'config value for the key "{key}" is "{value}", '
                             f'but the desired new value is '
                             f'"{second[key]}"'))
                return True
            second.pop(key, None)
    if len(second.keys()):
        return True
    logger.info(f'No update is required for the connector named "{name}"')
    return False


def config_has_changed(connect_endpoint, config):
    existing_config = get_current_config(connect_endpoint, config['name'])
    new_config = copy.deepcopy(config)
    name = config['name']
    return _dict_diff(name, existing_config, new_config)


def _update_connector(connect_endpoint, config):
    name = config['name']
    url = f'{connect_endpoint}/connectors/{name}/config'
    config['config']['name'] = name
    r = requests.put(url, json=config['config'])
    if r.status_code != 200:
        raise Exception((f'Error when updating connector config. '
                         f'Status code was {r.status_code}. '
                         f'Message was "{r.text}"'))
    logger.info(f'Successfully updated connector named "{name}"')


def _create_connector(connect_endpoint, config):
    url = f'{connect_endpoint}/connectors'
    r = requests.post(url, json=config)
    if r.status_code != 201:
        raise Exception((f'Error when creating connector config. '
                         f'Status code was {r.status_code}. '
                         f'Message was "{r.text}"'))
    name = config['name']
    logger.info(f'Successfully created connector named "{name}"')


def create_connector(config, connect_endpoint, overwrite_config):
    name = config['name']
    exists = connector_exists(connect_endpoint, name)
    if exists:
        logger.info((f'A connector named "{name}" already exists. Checking '
                       'if an update is required.'))
        if config_has_changed(connect_endpoint, config):
            if overwrite_config:
                _update_connector(connect_endpoint, config)
            else:
                logger.warning(f'The connector named "{name}" exists, and the '
                            'target configuration is different. Run this '
                            'tool with the "--overwrite" argument to update '
                            'it.')
    else:
        logger.info(f'A connector named "{name}" does not exist. Creating it')
        _create_connector(connect_endpoint, config)


def main(connect_endpoint, config_dir, overwrite):
    if connect_endpoint.endswith('/'):
        connect_endpoint = connect_endpoint[:-1]
    configs = get_configs(config_dir)
    for config in configs:
        logger.info(f'Processing config {config}')
        validate_config(config)
        create_connector(config, connect_endpoint, overwrite)


if __name__ == '__main__':
    args = parse_args()
    endpoint = args.connect_endpoint
    config_dir = args.config_dir
    overwrite = args.overwrite_config

    main(endpoint, config_dir, overwrite)

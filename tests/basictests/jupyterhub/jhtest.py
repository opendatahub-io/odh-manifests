import os
import sys
import time
from distutils.util import strtobool

from selenium import webdriver
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.chrome.options import Options  
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.support.select import Select

from selenium.common.exceptions import NoSuchElementException


import time

import logging

logging.basicConfig(level=logging.INFO)
_LOGGER = logging.getLogger()
_SCREENSHOT_DIR=f"{os.environ.get('ARTIFACT_SCREENSHOT_DIR', '/tmp')}"

class JHStress():
    def __init__(self):
        self.load_config()
        chrome_options = Options()  
        if self.headless:
            chrome_options.add_argument("--headless")
            chrome_options.add_argument('--no-sandbox')
            chrome_options.add_argument('--window-size=1420,1080')
            chrome_options.add_argument('--disable-gpu')
            chrome_options.add_argument('--disable-dev-shm-usage')
            chrome_options.add_argument('--ignore-certificate-errors')
        self.driver = webdriver.Chrome(chrome_options=chrome_options)
        self.driver.get(self.url)
        _LOGGER.info("Using JupyterHub URL %s" % self.url)
        self.action = ActionChains(self.driver)
        _LOGGER.info("Config loaded, driver initialized")

    def load_config(self):

        self.url = os.environ.get('JH_URL')
        self.username = os.environ.get('JH_LOGIN_USER')
        self.password = os.environ.get('JH_LOGIN_PASS')
        self.login_provider = os.environ.get('OPENSHIFT_LOGIN_PROVIDER', 'htpasswd-provider')
        self.notebooks = os.environ.get('JH_NOTEBOOKS', "").split(",")
        self.user_name = os.environ.get('JH_USER_NAME', 'test-user1')
        self.spawner = {
            "image": os.environ.get('JH_NOTEBOOK_IMAGE', "s2i-spark-minimal-notebook:3.6"),
            "size": os.environ.get('JH_NOTEBOOK_SIZE', "Default"),
            "gpu": os.environ.get('JH_NOTEBOOK_GPU', "0"),
        }
        self.as_admin = strtobool(os.environ.get('JH_AS_ADMIN', 'False'))
        self.headless = strtobool(os.environ.get('JH_HEADLESS', 'False'))
        self.preload_repos = os.environ.get('JH_PRELOAD_REPOS', "https://github.com/opendatahub-io/testing-notebooks")


        if not self.url:
            _LOGGER.error("You need to provide $JH_URL env var.")
            raise Exception("You need to provide $JH_URL env var.")

    def click_menu(self, button):
        cell_elem = self.driver.find_element(By.XPATH, '//a[text()="%s"]' % button)
        cell_elem.click()

    def openshift_login(self, username, password):
        username_elem = self.driver.find_element_by_id("inputUsername")
        username_elem.send_keys(username)
        password_elem = self.driver.find_element_by_id("inputPassword")
        password_elem.send_keys(password)
        login_elem = self.driver.find_element(By.XPATH, '//button[text()="Log in"]')
        login_elem.send_keys(Keys.RETURN)

    def go_to_admin(self):
        if not self.check_exists_by_xpath("//a[@href='/hub/admin']"):
            w = WebDriverWait(self.driver, 10)
            cp_elem = w.until(EC.element_to_be_clickable((By.XPATH, "//a[@href='/hub/home']")))
            cp_elem.click()
        admin_elem = self.driver.find_element_by_link_text("Admin")
        admin_elem.click()
        _LOGGER.info("Admin console")

    def admin_add_user(self):
        self.go_to_admin()

        user_elem = None
        try:
            user_elem = self.driver.find_element(By.XPATH, '//tr[@data-user="%s"]' % self.user_name)
        except:
            pass

        if user_elem:
            _LOGGER.info("User %s exists, cleaning up" % self.user_name)
            self.admin_del_user()

        _LOGGER.info("User %s does not exist" % self.user_name)
        textarea_visible = False
        retry = 0
        while not textarea_visible and retry < 4:
            add_user_elem = self.driver.find_element(By.ID, "add-users")
            add_user_elem.click()

            try:
                w = WebDriverWait(self.driver, 1)
                user_input_elem = w.until(EC.visibility_of_element_located((By.XPATH, '//textarea[@class="form-control username-input"]')))
            except Exception as ex:
                retry += 1
                continue
            textarea_visible = True

        user_input_elem.clear()
        user_input_elem.send_keys(self.user_name)

        save_users_elem = self.driver.find_element(By.XPATH, '//button[text()="Add Users"]')
        save_users_elem.click()
            

        w = WebDriverWait(self.driver, 30)
        start_elem = w.until(EC.element_to_be_clickable((By.XPATH, '//a[@href="/hub/spawn/%s"]' % self.user_name)))
        start_elem.click()

    def admin_del_user(self):
        self.go_to_admin()

        #TODO: Figure out why this sometimes fails
        retry = 2
        self.driver.implicitly_wait(10)
        stop_elem = self.driver.find_element_by_xpath('//tr[@data-user="%s"]/td[4]/a[1]' % self.user_name)
        if "hidden" in stop_elem.get_attribute("class"):
            _LOGGER.info("Server already stopped")
        else:
            _LOGGER.info("Stopping the server")
            time.sleep(5)
            stop_elem.click()
        
        w = WebDriverWait(self.driver, 50)
        start_elem = w.until(EC.element_to_be_clickable((By.XPATH, '//a[@href="/hub/spawn/%s"]' % self.user_name)))

        del_elem = w.until(EC.element_to_be_clickable((By.XPATH, '//tr[@data-user="%s"]//a[text()="delete user"]' % self.user_name)))
        del_elem.click()

        confirm_del_elem  = w.until(EC.element_to_be_clickable((By.XPATH, '//button[text()="Delete User"]')))
        confirm_del_elem.click()

    def run(self):
        try:
            self.login()
            _LOGGER.info("Logged in")
            if self.as_admin:
                self.admin_add_user()
                _LOGGER.info("Added user %s as admin" % self.user_name)
            self.spawn()
            _LOGGER.info("Spawned the server")
            tab = self.driver.window_handles[0]

            for notebook in self.notebooks:
                self.run_notebook(notebook, tab)
                _LOGGER.info("Notebook %s finished" % notebook)
            if self.as_admin:
                self.admin_del_user()
                _LOGGER.info("Deleted user %s" % self.user_name)
            else:
                self.stop()
                _LOGGER.info("Stopped the server")
        except Exception as e:
            _LOGGER.error(e)
            self.driver.get_screenshot_as_file(os.path.join(_SCREENSHOT_DIR, "exception.png"))
            raise e

    def deal_with_privacy_error(self):
        if "Privacy error" in self.driver.title:
            elem = self.driver.find_element_by_id("details-button")
            elem.send_keys(Keys.RETURN)
            elem = self.driver.find_element_by_id("proceed-link")
            elem.send_keys(Keys.RETURN)
        
    def login(self):
        self.deal_with_privacy_error()

        if self.check_exists_by_xpath('//*[@id="login-main"]/div/a'):
            elem = self.driver.find_element_by_xpath('//*[@id="login-main"]/div/a')
            elem.send_keys(Keys.RETURN)

        if self.check_exists_by_xpath('//a[text()="%s"]' % self.login_provider):
            elem = self.driver.find_element_by_link_text(self.login_provider)
            elem.send_keys(Keys.RETURN)
            self.openshift_login(self.username, self.password)

        permissions_xpath = '//input[@value="Allow selected permissions"]'
        if self.check_exists_by_xpath(permissions_xpath):
            elem = spawn_elem = self.driver.find_element(By.XPATH, permissions_xpath)
            elem.send_keys(Keys.RETURN)
    
    def test_environment_variables(self):
        _LOGGER.info("Testing Environment Variables")
        self.add_environment_variable('foo', 'bar')
        self.add_environment_variable('foo1', 'bar1')
        self.remove_last_environment_variable()
        self.remove_last_environment_variable()
    
    def add_environment_variable(self, key, value):
        self.driver.implicitly_wait(10)
        add_button_elem = self.driver.find_element(By.XPATH, '//*[@id="root"]/div/header/form/form/button')
        add_button_elem.send_keys(Keys.RETURN)
        key_elem = self.driver.find_element(By.ID, 'KeyForm-') # Name should be empty so newly created forms have this id.
        value_elem = self.driver.find_element(By.ID, 'ValueForm-')
        key_elem.send_keys(key) # No clearing neccessary.
        value_elem.send_keys(value)

    def remove_last_environment_variable(self):
        remove_button_elems = self.driver.find_elements(By.CLASS_NAME, 'btn-danger')
        elem = remove_button_elems[len(remove_button_elems) - 1]
        elem.send_keys(Keys.RETURN)

    def spawn(self):
        image_drop = self.driver.find_element(By.XPATH, '//*[@id="ImageDropdownBtn"]')
        image_drop.send_keys(Keys.RETURN)

        self.driver.implicitly_wait(30)
        image_select = self.driver.find_element_by_id(self.spawner["image"])
        image_select.click()

        size_drop = self.driver.find_element(By.XPATH, '//*[@id="SizeDropdownBtn"]')
        size_drop.click()

        size_select = self.driver.find_element_by_id(self.spawner["size"])
        size_select.click()

        gpu_elem = self.driver.find_element(By.XPATH, '//*[@id="gpu-form"]')
        gpu_elem.clear()
        gpu_elem.send_keys(self.spawner['gpu'])

        self.test_environment_variables()

        time.sleep(0.5)

        self.add_environment_variable("JUPYTER_PRELOAD_REPOS", self.preload_repos)

        gpu_elem.send_keys(Keys.RETURN)

    def stop(self):
        self.driver.get(self.url+ "/hub/home")
        stop_elem = self.driver.find_element_by_id("stop")
        stop_elem.click()

    def run_notebook(self, notebook, tab):
        path = notebook.split("/")
        w = WebDriverWait(self.driver, 300)
        auth_elem = w.until(EC.presence_of_element_located((By.XPATH, '/html/body/div[1]/div/form/input')))
        auth_elem.click()
        if len(path) > 1:
            for segment in path[:-1]:
                w = WebDriverWait(self.driver, 10)
                dir_elem = w.until(EC.presence_of_element_located((By.XPATH, '//span[text()="%s"]' % segment)))
                dir_elem.click()

        _LOGGER.info("Executing notebook %s" % path[-1])
        notebook_elem = w.until(EC.presence_of_element_located((By.XPATH, '//span[text()="%s"]' % path[-1])))
        notebook_elem.click()

        #Switch to new tab
        self.driver.switch_to_window(self.driver.window_handles[1])

        self.run_all_cells()
        self.driver.close()
        self.driver.switch_to_window(tab)

    def run_all_cells(self):
        try:
            w = WebDriverWait(self.driver, 30)
            element = w.until(EC.presence_of_element_located((By.XPATH, '//i[@id="kernel_indicator_icon"][@title="Kernel Idle"]')))
        except Exception as e:
            _LOGGER.error(e)
            raise e

        wait = WebDriverWait(self.driver, 10)
        elem = wait.until(EC.element_to_be_clickable((By.XPATH, '//a[text()="Cell"]')))

        self.click_menu("Cell")
        elem = self.driver.find_element_by_id("all_outputs")
        self.driver.execute_script("arguments[0].setAttribute('class','dropdown-submenu open')", elem)

        clear_elem = self.driver.find_element_by_id("clear_all_output")
        clear_elem.click()

        self.click_menu("Cell")
        self.click_menu("Run All")

        cells = self.driver.find_elements(By.XPATH, '//div[contains(@class, "cell code_cell")]')

        last = len(cells)
        wait_time = 180
        retries = int(wait_time/2)
        last_cell = None
        for i in range(0, retries):
            last_cell = self.driver.find_element(By.XPATH, '(//div[contains(@class, "cell code_cell")])[%d]//div[@class="prompt_container"]' % last)
            if last_cell.text == "In [*]:" or last_cell.text == "In [ ]:":
                time.sleep(2)
            else:
                break

        _LOGGER.info("Reached last cell, execution numbering: '%s'" % last_cell.text)

    def quit(self):
        self.driver.quit()

    def check_exists_by_xpath(self, xpath):
        try:
            self.driver.find_element_by_xpath(xpath)
        except NoSuchElementException:
            return False
        return True


if __name__ == "__main__":
    jhs = JHStress()
    jhs.run()
    jhs.quit()

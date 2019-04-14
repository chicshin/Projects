from selenium import webdriver

path = '/Users/janeshin/Downloads/chromedriver'

driver = webdriver.Chrome(path)
driver.implicitly_wait(3)
driver.get('http://www.instagram.com/accounts/login')

assert "Instagram" in driver.title

def login(username, password):
    elem = driver.find_element_by_name('username')
    elem.send_keys(username)

    elem = driver.find_element_by_name('password')
    elem.send_keys(password)

    elem.submit()

login('your_username','your_password')

"""
Goal:
Most Used Hashtags.
Find the most useful hashtags that may help inducing likes and followers among the each top 3 popular instagram users' hashtags.
"""

from time import sleep
from selenium import webdriver
from selenium.webdriver.common.action_chains import ActionChains
from selenium.webdriver.common.keys import Keys
from selenium.common.exceptions import TimeoutException
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.common.by import By
import csv


"""
Future Goal:
CLEAN CODE
- Create a class (login session/search bar engine)
Once moved to user's account,
- Create class that collects hashtags from recent 50 posts
- Save the hashtags in csv file to proceed analysis
"""

driver = webdriver.Chrome('/Users/janeshin/Downloads/chromedriver')
driver.implicitly_wait(20)
driver.get('https://www.instagram.com/')

sleep(3)


login_elem = driver.find_element_by_xpath(
	'//*[@id="react-root"]/section/main/article/div[2]/div[2]/p/a')
login_elem.click()

sleep(2)


def login(usrname, pwd):
    elem = driver.find_element_by_name('username')
    elem.send_keys(usrname)

    elem = driver.find_element_by_name('password')
    elem.send_keys(pwd)

    elem.submit()
login('your_username','your_password')

sleep(3)


# click 'Not Now' on notification pop-up displayed
def notification_popup():
    WebDriverWait(driver, 10).until(EC.element_to_be_clickable((By.CSS_SELECTOR, ".aOOlW.HoLwm"))).click()
notification_popup()

sleep(3)


# type in user's id in search bar
search = driver.find_element_by_css_selector(
	'#react-root > section > nav > div._8MQSO.Cx7Bp > div > div > div.LWmhU._0aCwM > input')

ActionChains(driver)\
.move_to_element(search).click()\
.send_keys('abanna_yoga_art')\
.perform()

sleep(3)


# click the id
name = driver.find_element_by_xpath(
	'//*[@id="react-root"]/section/nav/div[2]/div/div/div[2]/div[2]/div[2]/div/a[1]/div')

ActionChains(driver)\
.move_to_element(name)\
.click().perform()

sleep(3)


# open up the first post
post = driver.find_element_by_class_name('_9AhH0')
post.click()


# load= browser.find_element_by_xpath(
# 	'/html/body/div[4]/div/div/div[2]/div/article/div[2]/div[1]/ul/li[2]/a')
#
# while True:
# 	try:
# 		button = WebDriverWait(load, 5).until(EC.visibility_of_element_located((By.XPATH,
#         	"/html/body/div[4]/div/div/div[2]/div/article/div[2]/div[1]/ul/li[2]/a")))
# 	except TimeoutException:
# 		break  # no more wines
# 	button.click()  # load more comments
#
#
#
# csv_file = open('insta2.csv', 'wb')
# writer = csv.writer(csv_file)
# writer.writerow(['hashtag'])
#
#
# hash_dict = {}
#
#
#
# tag = browser.find_element_by_xpath("/html/body/div[4]/div/div/div[2]/div/article/div[2]/div[1]/ul/li[4]/span").text
# hash_dict["hashtag"] = tag
# writer.writerow(hash_dict.values())
#
#
# browser.back()

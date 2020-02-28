from pyvirtualdisplay import Display
from selenium import webdriver

display = Display(visible=0, size=(1366, 768))
display.start()
browser = webdriver.Firefox()
#browser.get('http://13.232.218.211:8081/')
browser.get('https://google.com')
print browser.title
browser.quit()

display.stop()

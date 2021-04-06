import os
import pyautogui

currentPath = os.getcwd()

os.startfile('sqlplus.exe')

pyautogui.sleep(.5)

pyautogui.typewrite("system")
pyautogui.typewrite(["enter"])

pyautogui.typewrite("12345")
pyautogui.typewrite(["enter"])

pyautogui.sleep(.5)

pyautogui.typewrite(
    f'@"{currentPath}\\main.sql"')
pyautogui.typewrite(["enter"])

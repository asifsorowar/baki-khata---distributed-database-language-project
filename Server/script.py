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
    f'@"{currentPath}\\comm.sql"')
pyautogui.typewrite(["enter"])

pyautogui.sleep(.5)

pyautogui.typewrite(
    f'@"{currentPath}\\triggers.sql"')
pyautogui.typewrite(["enter"])

pyautogui.sleep(.5)

pyautogui.typewrite(
    f'@"{currentPath}\\package.sql"')
pyautogui.typewrite(["enter"])

pyautogui.sleep(3)

pyautogui.keyDown('ctrl')
pyautogui.press('z')
pyautogui.keyUp('ctrl')
pyautogui.press('enter')

"""Pruebas de navegador. Requiere selenium, Chrome y servidor en localhost:8000."""
import unittest
from selenium import webdriver
from selenium.webdriver.common.by import By


class CuotasBrowserTest(unittest.TestCase):
    def setUp(self):
        options = webdriver.ChromeOptions()
        options.add_argument('--headless=new')
        options.add_argument('--no-sandbox')
        self.driver = webdriver.Chrome(options=options)
        self.driver.get('http://localhost:8000')
        self.driver.find_element(By.ID, 'reiniciar').click()

    def tearDown(self):
        self.driver.quit()

    def test_aprobar_actualiza_habilitacion(self):
        self.assertEqual(self.driver.find_element(By.ID, 'habilitacion').text, 'No habilitado')
        self.driver.find_element(By.ID, 'aprobar').click()
        self.assertEqual(self.driver.find_element(By.ID, 'habilitacion').text, 'Habilitado')

    def test_rechazar_conserva_deuda(self):
        self.driver.find_element(By.ID, 'rechazar').click()
        self.assertEqual(self.driver.find_element(By.ID, 'habilitacion').text, 'No habilitado')


if __name__ == '__main__':
    unittest.main()


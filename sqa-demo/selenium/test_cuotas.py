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
        self.driver.find_element(By.XPATH, "//button[normalize-space()='Aprobar']").click()
        self.assertEqual(self.driver.find_element(By.ID, 'habilitacion').text, 'Habilitado')

    def test_rechazar_conserva_deuda(self):
        self.driver.find_element(By.XPATH, "//button[normalize-space()='Rechazar']").click()
        self.assertEqual(self.driver.find_element(By.ID, 'habilitacion').text, 'No habilitado')

    def test_agregar_cuota_y_solicitar_revision(self):
        self.driver.find_element(By.ID, 'periodo').send_keys('noviembre 2026')
        self.driver.find_element(By.ID, 'importe').send_keys('120')
        self.driver.execute_script(
            "arguments[0].value = '2026-11-20';",
            self.driver.find_element(By.ID, 'vencimiento'),
        )
        self.driver.find_element(By.XPATH, "//button[normalize-space()='Agregar cuota']").click()
        self.assertIn('Cuota agregada.', self.driver.find_element(By.ID, 'mensaje').text)
        self.driver.find_element(By.XPATH, "//button[normalize-space()='Solicitar revisión']").click()
        self.assertIn('Solicitud enviada a revisión.', self.driver.find_element(By.ID, 'mensaje').text)


if __name__ == '__main__':
    unittest.main()


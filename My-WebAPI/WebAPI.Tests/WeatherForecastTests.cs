namespace WebAPI.Tests
{
    [TestClass]
    public class WeatherForecastTests
    {
        [DataTestMethod]
        [DataRow(-40, -40)]
        [DataRow(0, 32)]
        [DataRow(20, 68)]
        [DataRow(100, 212)]
        public void TemperatureF_ReturnsCorrectValue(int temperatureC, int expectedTemperatureF)
        {
            // Arrange
            var forecast = new WeatherForecast
            {
                TemperatureC = temperatureC
            };

            // Act
            var result = forecast.TemperatureF;

            // Assert
            Assert.AreEqual(expectedTemperatureF, result);
        }
    }
}
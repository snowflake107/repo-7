using Microsoft.Extensions.Logging;
using Moq;
using WebAPI.Controllers;

namespace WebAPI.Tests.Controllers
{
    [TestClass]
    public class WeatherForecastControllerTests
    {
        [TestMethod]
        public void Get_ReturnsFiveWeatherForecasts()
        {
            // Arrange
            var loggerMock = new Mock<ILogger<WeatherForecastController>>();
            var controller = new WeatherForecastController(loggerMock.Object);

            // Act
            var result = controller.Get();

            // Assert
            Assert.AreEqual(5, result.Count());
        }

        [TestMethod]
        public void Get_ReturnsWeatherForecastsWithValidData()
        {
            // Arrange
            var loggerMock = new Mock<ILogger<WeatherForecastController>>();
            var controller = new WeatherForecastController(loggerMock.Object);

            // Act
            var result = controller.Get();

            // Assert
            foreach (var forecast in result)
            {
                Assert.IsTrue(forecast.TemperatureC >= -20 && forecast.TemperatureC <= 55);
                Assert.IsTrue(WeatherForecastController.GetSummaries().Contains(forecast.Summary));
            }
        }
    }
}

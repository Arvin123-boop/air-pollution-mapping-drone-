// #include <Adafruit_BMP280.h>  // Library for BMP280
// #include <Wire.h>              // For I2C communication

// // --- Pin Definitions ---
// #define MQ135_PIN 34     // Analog pin for MQ135 gas sensor
// #define SOUND_PIN 35     // Analog pin for HW-484 sound sensor

// // --- BMP280 Setup ---
// Adafruit_BMP280 bmp; // I2C connection

// void setup() {
//   Serial.begin(115200);
//   delay(1000);
//   Serial.println("Starting sensors...");

//   // Initialize BMP280
//   if (!bmp.begin(0x76)) {  // 0x76 is the most common address
//     Serial.println("Could not find BMP280 sensor!");
//     while (1);
//   } else {
//     Serial.println("BMP280 connected successfully!");
//   }

//   // Set up analog input pins
//   pinMode(MQ135_PIN, INPUT);
//   pinMode(SOUND_PIN, INPUT);
// }

// void loop() {
//   // --- BMP280 readings ---
//   float temperature = bmp.readTemperature();
//   float pressure = bmp.readPressure() / 100.0; // convert to hPa
//   float altitude = bmp.readAltitude(1013.25);  // estimated altitude

//   // --- MQ135 readings ---
//   int mq135Value = analogRead(MQ135_PIN);

//   // --- HW-484 Sound Sensor readings ---
//   int soundValue = analogRead(SOUND_PIN);

//   // --- Print all sensor data ---
//   Serial.println("===== SENSOR READINGS =====");
//   Serial.print("Temperature: "); Serial.print(temperature); Serial.println(" °C");
//   Serial.print("Pressure: "); Serial.print(pressure); Serial.println(" hPa");
//   Serial.print("Approx Altitude: "); Serial.print(altitude); Serial.println(" m");
//   Serial.print("MQ135 Gas Value: "); Serial.println(mq135Value);
//   Serial.print("Sound Sensor Value: "); Serial.println(soundValue);
//   Serial.println("============================\n");

//   delay(2000);  // read every 2 seconds
// }
#include <Wire.h>
#include <Adafruit_BMP280.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

// ---------- WIFI ----------
#define WIFI_SSID "Irvin's A72"
#define WIFI_PASSWORD "12345678"

// ---------- FIREBASE ----------
#define API_KEY "AIzaSyDDs_Nz8qFt4H6KAJ3Ro5BNjIrV-1fgu2w"
#define DATABASE_URL "https://esp-32-sending-data-default-rtdb.asia-southeast1.firebasedatabase.app/"

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ---------- SENSORS ----------
Adafruit_BMP280 bmp;
#define MQ135_PIN 34
#define SOUND_PIN 35
#define LIGHT_PIN 32

void setup() {
  Serial.begin(115200);

  // BMP280 setup
  if (!bmp.begin(0x76)) {
    Serial.println("BMP280 not found!");
    while (1);
  }

  // WiFi setup
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println("\nWiFi connected!");

  // Firebase setup
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  auth.user.email = "arvin26otgoo@gmail.com";
  auth.user.password = "Arvin.123456";

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  // ----- BMP280 -----
  float temperature = bmp.readTemperature();
  float pressure = bmp.readPressure() / 100.0;

  // ----- MQ135 -----
  int mq135Value = analogRead(MQ135_PIN);

  // ----- HW-484 -----
  int soundValue = analogRead(SOUND_PIN);

  // ----- LED Sensor -----
  int lightValue = analogRead(LIGHT_PIN);

  // ----- Print to Serial -----
  Serial.println("==== Sensor Readings ====");
  Serial.print("Temperature: "); Serial.print(temperature); Serial.println(" °C");
  Serial.print("Pressure: "); Serial.print(pressure); Serial.println(" hPa");
  Serial.print("MQ135: "); Serial.println(mq135Value);
  Serial.print("Sound: "); Serial.println(soundValue);
  Serial.print("Light: "); Serial.println(lightValue);
  Serial.println("==========================");

  // ----- Send to Firebase -----
  FirebaseJson json;
  json.set("temperature", temperature);
  json.set("pressure", pressure);
  json.set("air_quality_mq135", mq135Value);
  json.set("sound_level", soundValue);
  json.set("light_level", lightValue);

  if (Firebase.RTDB.setJSON(&fbdo, "/sensorData", &json))
    Serial.println("✅ Data sent to Firebase!");
  else
    Serial.println(fbdo.errorReason());

  delay(5000);
}


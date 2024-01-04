#include <Arduino.h>
/**
 * Based on code created by K. Suwatchai (Mobizt)
 * https://github.com/mobizt/Firebase-ESP-Client/blob/main/examples/RTDB/DataChangesListener/Callback/Callback.ino
 */

#if defined(ESP32)
#include <WiFi.h>
#elif defined(ESP8266)
#include <ESP8266WiFi.h>
#endif

#include "secrets.h"

#include <Firebase_ESP_Client.h>

// Provide the token generation process info.
#include <addons/TokenHelper.h>

// Provide the RTDB payload printing info and other helper functions.
#include <addons/RTDBHelper.h>

#define BUFFER_LENGTH 10
// Define Firebase Data object
FirebaseData stream;
FirebaseData fbdo;

FirebaseAuth auth;
FirebaseConfig config;

unsigned long deleteCommandPrevMillis = 0;

int count = 0;

volatile bool dataChanged = false;

volatile bool initial_read = true;

unsigned int command_buffer[BUFFER_LENGTH]={0};
int buffer_size=0;
String name_buffer[BUFFER_LENGTH]={""};

unsigned int getLastNonZeroIndex() {
  for (int i = BUFFER_LENGTH - 1; i >= 0; i--) {
    if (command_buffer[i] != 0) {
      return i;
    }
  }
  return -1; // return -1 if all values are zero
}

void streamCallback(FirebaseStream data)
{
  Serial.printf("sream path, %s\nevent path, %s\ndata type, %s\nevent type, %s\n\n",
                data.streamPath().c_str(),
                data.dataPath().c_str(),
                data.dataType().c_str(),
                data.eventType().c_str());
  // printResult(data); // see addons/RTDBHelper.h


  if (data.dataTypeEnum() == firebase_rtdb_data_type_json)
  {
  FirebaseJson *json = data.to<FirebaseJson *>();
  Serial.println((const char *)FPSTR("Iterate JSON data:"));
  Serial.println();
  size_t numElements = json->iteratorBegin();
  Serial.printf("numElements = %d\n", numElements);
  FirebaseJson::IteratorValue value;
    if(getLastNonZeroIndex()==-1)
  {
    buffer_size=0;
  } else {
    buffer_size=getLastNonZeroIndex();
  }
  Serial.printf("buffer_size before = %d\n", buffer_size);
  for (int index = numElements - 1; index >= 0; index--) // iterate in reverse order from the end of the json
  {
    value = json->valueAt(index);
    Serial_Printf((const char *)FPSTR("%d, Name: %s, Value: %s\n"), index, value.key.c_str(), value.value.c_str());
    // here we add each command
    int new_item_index = buffer_size + numElements - index - 1;
    command_buffer[new_item_index] = value.value.toInt();
    name_buffer[new_item_index] = value.key.c_str();
  }
  json->iteratorEnd();
  json->clear();

  buffer_size += numElements;
  Serial.printf("buffer_size after = %d\n", buffer_size);
  }
  else if (data.dataTypeEnum()==firebase_rtdb_data_type_integer)
  {
    buffer_size=getLastNonZeroIndex();
    int new_item_index=buffer_size+1; 
    Serial.printf("inserting at index %d\n",new_item_index);
    command_buffer[new_item_index]=data.to<int>();
    name_buffer[new_item_index]=data.dataPath().c_str();
    Serial.printf("buffer_size after= %d\n",buffer_size);
    buffer_size=new_item_index;
  }
  Serial.println();
 
  // This is the size of stream payload received (current and max value)
  // Max payload size is the payload size under the stream path since the stream connected
  // and read once and will not update until stream reconnection takes place.
  // This max value will be zero as no payload received in case of ESP8266 which
  // BearSSL reserved Rx buffer size is less than the actual stream payload.
  Serial.printf("Received stream payload size: %d (Max. %d)\n\n", data.payloadLength(), data.maxPayloadLength());

  // Due to limited of stack memory, do not perform any task that used large memory here especially starting connect to server.
  // Just set this flag and check it status later.
  dataChanged = true;
}


void deleteCommand(size_t index)
{
  //add "/command/type" to the name_buffer item
      if (!command_buffer[index]==0)
      {
      String path = "/command/type/" + name_buffer[index]; 
      // Serial.printf("path = %s\n",path.c_str());
      Firebase.RTDB.deleteNode(&fbdo, path.c_str());
      // Serial.println(fbdo.errorReason());
      command_buffer[index]=0;
      name_buffer[index]="";
      buffer_size=getLastNonZeroIndex();
      }
      else
      {
        Serial.printf("command_buffer[%d] is zero, skipping\n",index);
      }
}
void streamTimeoutCallback(bool timeout)
{
  if (timeout)
    Serial.println("stream timed out, resuming...\n");

  if (!stream.httpConnected())
    Serial.printf("error code: %d, reason: %s\n\n", stream.httpCode(), stream.errorReason().c_str());
}

void setup()
{

  Serial.begin(115200);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED)
  {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);

  /* Assign the api key (required) */
  config.api_key = API_KEY;

  /* Assign the user sign in credentials */
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  /* Assign the RTDB URL (required) */
  config.database_url = DATABASE_URL;

  /* Assign the callback function for the long running token generation task */
  config.token_status_callback = tokenStatusCallback; // see addons/TokenHelper.h

  // Or use legacy authenticate method
  // config.database_url = DATABASE_URL;
  // config.signer.tokens.legacy_token = "<database secret>";

  // To connect without auth in Test Mode, see Authentications/TestMode/TestMode.ino

  Firebase.begin(&config, &auth);

  Firebase.reconnectWiFi(true);

// Recommend for ESP8266 stream, adjust the buffer size to match your stream data size
#if defined(ESP8266)
  stream.setBSSLBufferSize(2048 /* Rx in bytes, 512 - 16384 */, 512 /* Tx in bytes, 512 - 16384 */);
#endif
  

  if (!Firebase.RTDB.beginStream(&stream, "/command/type"))
    Serial.printf("stream begin error, %s\n\n", stream.errorReason().c_str());

  Firebase.RTDB.setStreamCallback(&stream, streamCallback, streamTimeoutCallback);


}

void loop()
{

  Firebase.ready(); // should be called repeatedly to handle authentication tasks.

  if (dataChanged)
  {
    dataChanged = false;
    Serial.printf("\n main loop detected data change \n");
  }

  if (millis()-deleteCommandPrevMillis > 5000)
  {
    deleteCommandPrevMillis = millis();
    buffer_size=getLastNonZeroIndex();
    Serial.printf("command buffer_size = %d\n",buffer_size);

    if (buffer_size >= 0)
    {
      //print the buffer
      for (int i = 0; i < 10; i++)
      {
        Serial.printf("command_buffer[%d] = %d\t",i,command_buffer[i]);
        Serial.printf("name_buffer[%d] = %s\n",i,name_buffer[i].c_str());
      }
      //print the current command in command_buffer
      Serial.printf("\n*** EXECUTING command = %d\n",command_buffer[buffer_size]);
      deleteCommand(buffer_size);
    }
  }
}

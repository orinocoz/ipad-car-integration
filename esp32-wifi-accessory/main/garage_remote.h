#ifndef IPAD_CAR_INTEGRATION_GARAGE_H_
#define IPAD_CAR_INTEGRATION_GARAGE_H_

#include <hap.h>
#include <driver/gpio.h>

typedef enum {
  CurrentDoorStateOpen = 0,
  CurrentDoorStateClosed,
  CurrentDoorStateOpening,
  CurrentDoorStateClosing,
  CurrentDoorStateStopped
} CurrentDoorState;

typedef enum {
  TargetDoorStateOpen = 0,
  TargetDoorStateClosed
} TargetDoorState;

class GarageRemote {
public:
  gpio_num_t powerButtonPin; // The brown-yellow wire in the car
  gpio_num_t openButtonPin; // The brown-white wire in the car
  gpio_num_t resetButtonPin;
  hap_acc_t* accessory;
  hap_acc_cfg_t accessoryConfig;
  TargetDoorState targetDoorState;
  CurrentDoorState currentDoorState;

  GarageRemote(gpio_num_t powerButtonPin, gpio_num_t openButtonPin, gpio_num_t resetButtonPin);
  void registerHomeKitAccessory();
  void startHomeKitAccessory();
  void printSetupQRCode();

  TargetDoorState getTargetDoorState();
  void setTargetDoorState(TargetDoorState state);

  CurrentDoorState getCurrentDoorState();

  void turnOffOpenButton();

private:
  void createAccessory();
  void addGarageDoorOpenerService();
  void addFirmwareUpgradeService();
  void configureHomeKitSetupCode();
  void initializeResetButton();
  void open();
};

#endif

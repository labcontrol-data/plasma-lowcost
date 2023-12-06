// Code Arduino Due
// Author: Alessandro N. Vargas (www.anvargas.com)
// Code reads voltage and current, and computes the power
// Code also reads voltage corresponding to the LDR sensor
// and converts the information to LUX
// Last update: UC Berkeley, Nov 29, 2023

  unsigned int V_out;
  int myVals[]={4000, 2200}; 
  int a0=0; int a1=0; int a2 = 0; int q1=0; int q2=0; int q3=0;
  float volts = 0; float current = 0; float power = 0; 
  float voltagelux = 0;
  const float c1 = 0.00080043337;
  const float c2 = 0.006706;
  const float c3 = 1865.823688;
  const float c4 = -1009.35;
  const float dc_offset_for_current = 1.2624;  // DC offset (V) measured in the circuit (see the published paper for details)
  const float gain_probe_1 = 934.712121; // measured gain of the low-cost high-voltage probe (see the published paper for details)
  const float gain_current_sensor = 0.04347826;  // equals one divided by R = 23 Ohms

void setup(){
  Serial.begin(115200);
  PWMC_ConfigureClocks(16000 * PWM_MAX_DUTY_CYCLE , 0, VARIANT_MCK);
  analogWrite(DAC0, 0);
  analogWriteResolution(12);  // set the analog output resolution to 12 bit (4096 levels)
  analogReadResolution(12);   // set the analog input resolution to 12 bit
}
void loop(){

  int count=0;
  while(count<4098)
  { 
     // ==========================================================
     // Code for analog read - reads 4 elements
     // and computes its mean (doing so helps reducing noise)
     // ==========================================================
     q1=0; q2=0; q3=0;
     for (int r = 1; r <= 4; r++) {
       q1 = q1 + analogRead(A0);
       q2 = q2 + analogRead(A1);
       q3 = q3 + analogRead(A2);
     }
     a0=q1/4;
     a1=q2/4;  
     a2=q3/4;
     volts = float ( (c1*a0) + c2 );
     //volts = gain_probe_1 * volts;
     Serial.print ("volts = ");
     Serial.print (volts,6);

     current = float ( (c1*a1) + c2 );
     current = current - dc_offset_for_current;
     current = gain_current_sensor * current; 
     Serial.print ("; current = ");
     Serial.print (current, 6);
     
     power = (gain_probe_1 *volts) * current;
     Serial.print ("; power = ");
     Serial.print (power, 6);
     
     voltagelux = float ( (c1*a2) + c2 );
     Serial.print ("; voltagelux = ");
     Serial.println (voltagelux, 4);
    
     // ==========================================================
     // Code for analog output - useless in this code
     // ==========================================================
     V_out = count;
     dacc_set_channel_selection(DACC_INTERFACE, 0);
     dacc_write_conversion_data(DACC_INTERFACE, V_out);
     
     delay(500);
     //delay(100);
     count = count+1;
  }
}

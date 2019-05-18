void tsk_PI(void* pvArgs);

void tsk_PI(void* pvArgs)
{
    PI controller = *((PI*)pvArgs);          //use pvArgs to set up the PI
    controller.conditional_anti = 1;
    int16_t error = 0;

    for (;;)
    {
       error = calculate_error_PI(controller.ref, controller.measured_y_n, &controller );
       calculate_PI( error, &controller );

       vTaskDelay(pdMS_TO_TICKS(100));
    }
}

typedef struct PI_dif_eq
{
    int16_t x_n[3];
    float y_n[3];
    float kp;
    float ki;
    float sample_rate;
    int16_t saturation;
    int16_t* ref;
    int16_t* PWM_out;
    int16_t* measured_y_n;
    int16_t* clamp_ref;
    uint8_t conditional_anti;
}PI;

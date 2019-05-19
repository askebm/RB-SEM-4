

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



void calculate_PI(int16_t error, PI* K)
{
    int16_t tmp_output = 0;
    K->x_n[2] = K->x_n[1];
    K->x_n[1] = K->x_n[0];
    K->x_n[0] = error;

    K->y_n[2] = K->y_n[1];
    K->y_n[1] = K->y_n[0];
    K->y_n[0] = K->y_n[1] + ( K->kp * (K->x_n[0] - K->x_n[1]) +
    ( K->conditional_anti * K->ki * K->sample_rate / 2) * (K->x_n[0] + K->x_n[1]) );
    K->conditional_anti = 1;

    tmp_output = K->y_n[0];

    if(tmp_output >= K->saturation)
    {
         tmp_output = K->saturation;
         K->conditional_anti = 0;
    }
    else
    {
        if (tmp_output <= -K->saturation)
        {
            tmp_output = -K->saturation;
            K->conditional_anti = 0;
        }
    }

    *K->PWM_out = tmp_output;
}

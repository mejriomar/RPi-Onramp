using PiGPIO
        pi = Pi()

        # Dim an LED to 40% on pin 18
        set_PWM_frequency(pi, 18, 1000)  # 1 kHz
        set_PWM_dutycycle(pi, 18, 102)   # 0–255 range
        sleep(2)
        set_PWM_dutycycle(pi, 18, 0)
        stop(pi)

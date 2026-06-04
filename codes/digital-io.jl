using PiGPIO

    pi = Pi()  # connect to pigpiod daemon

    const LED_PIN = 17  # BCM numbering
    const BTN_PIN = 27

    set_mode(pi, LED_PIN, OUTPUT)
    set_mode(pi, BTN_PIN, INPUT)
    set_pull_up_down(pi, BTN_PIN, PUD_UP)   # internal pull-up

    # Read button, mirror to LED
    while true
        level = read(pi, BTN_PIN)  # returns 0 or 1
        write(pi, LED_PIN, level == 0 ? 1 : 0)
        sleep(0.01)
    end

    stop(pi)  # release daemon connection
    

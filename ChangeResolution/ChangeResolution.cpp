#include <stdio.h>
#include <windows.h>
#include <winuser.h>
#include <iostream>
#include <vector>

int main() {

    //DEVMODE devmode;
    //devmode.dmPelsWidth = 1024;
    //devmode.dmPelsHeight = 768;
    //devmode.dmSize = sizeof(DEVMODE);

    //long result = ChangeDisplaySettings(&devmode, 0);


    //std::vector<std::pair<int, int>> m_modes;
    //DEVMODE dm = { 0 };
    //dm.dmSize = sizeof(dm);
    //for (int iModeNum = 0; EnumDisplaySettings(NULL, iModeNum, &dm) != 0; iModeNum++) {
    //    m_modes.push_back(std::make_pair(dm.dmPelsWidth, dm.dmPelsHeight));
    //}


    //for (int i = 0; i < 15; i++)
    //    std::cout << dm.dmDeviceName << std::endl;


    //DEVMODE desiredMode = { 1 };
    //desiredMode.dmSize = sizeof(DEVMODE);
    //desiredMode.dmPelsWidth = 800;
    //desiredMode.dmPelsHeight = 600;
    //desiredMode.dmFields = DM_PELSHEIGHT | DM_PELSWIDTH;
    //LONG res = ChangeDisplaySettings(&desiredMode, CDS_UPDATEREGISTRY | CDS_GLOBAL | CDS_RESET);


    DWORD DispNum = 0;
    DISPLAY_DEVICE DisplayDevice;
    DEVMODE defaultMode;
    HDC hdc;
    int nWidth;
    BOOL bFoundSecondary = FALSE;

    hdc = GetDC(0);
    nWidth = GetDeviceCaps(hdc, HORZRES);
    ReleaseDC(0, hdc);

    // Initialize DisplayDevice.
    ZeroMemory(&DisplayDevice, sizeof(DisplayDevice));
    DisplayDevice.cb = sizeof(DisplayDevice);

    // Get display devices.
    while ((EnumDisplayDevices(NULL, DispNum, &DisplayDevice, 0)) && (bFoundSecondary == FALSE))
    {
        ZeroMemory(&defaultMode, sizeof(DEVMODE));
        defaultMode.dmSize = sizeof(DEVMODE);
        if (!EnumDisplaySettings((LPTSTR)DisplayDevice.DeviceName, ENUM_REGISTRY_SETTINGS, &defaultMode)) {
            printf("1\n");
            return FALSE; // Store default failed
        }

        if (!(DisplayDevice.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE)) {
            //Found the first secondary device.
            printf(("Found the first secondary device: Name: %s, Pos: %d, Width: %d\n"), DisplayDevice.DeviceName, defaultMode.dmPosition.x, nWidth);
            bFoundSecondary = TRUE;
            defaultMode.dmPosition.x = 0; // LINE CHANGED: ONLY CHANGE FROM MSDN'S CODE
            defaultMode.dmFields = DM_POSITION;
            ChangeDisplaySettingsEx((LPTSTR)DisplayDevice.DeviceName, &defaultMode, NULL, CDS_NORESET | CDS_UPDATEREGISTRY, NULL);
            printf(("Check for error: %u\n"), GetLastError()); // prints "Check for error: 0" which means no error occurred

            // A second call to ChangeDisplaySettings updates the monitor.
            ChangeDisplaySettings(NULL, 0);
            printf(("Check for error: %u\n"), GetLastError()); // prints "Check for error: 0" which means no error occurred
        }

        // Reinitialize DisplayDevice. 
        ZeroMemory(&DisplayDevice, sizeof(DisplayDevice));
        DisplayDevice.cb = sizeof(DisplayDevice);
        DispNum++;
    } // End while the display devices. 

    return 0;
}
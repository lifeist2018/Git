#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include "RobotController.h"
#include "Filter.h"
#include "QFile.h"

namespace Ui {
class MainWindow;
}

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

private:
	QTimer *m_ForceCollectTimer;
	ForceFilter *m_ForceFilter;
	vector<vector<double>> m_Force;

	void OutputFile();
	void WriteInfo(std::vector<std::vector<double>> infoList,QString name);
	void SetList(vector<vector<double>> &list,double data[6]);
private slots:
	void slotForceCollectTimerDone();
	void on_pButton_StartCollect_clicked();
	void on_pButton_EndCollect_clicked();
    void on_pButton_Connect_clicked();
	void on_pButton_Disconnect_clicked();
    void on_robotcontroller_connect();
	void on_robotcontroller_disconnect();
	void on_robotcontroller_neartotarget();
	void on_robotcontroller_poweroff();
	void on_robotcontroller_idle();
	void on_robotcontroller_run();
	void on_robotcontroller_exceedpositionlimit(bool);
	void on_robotcontroller_neartopositionlimit(bool);
	void on_robotcontroller_exceedspeedlimit(bool);
	void on_robotcontroller_ReceiveData(const AsySocketClient::RobotState &);
	void on_pButton_OpenRobotModel_clicked();
	void on_pButton_OpenRobotSimulate_clicked();
	void on_pButton_OpenRobotControl_clicked();
	void on_pButton_ShutDown_clicked();
	void on_pButton_PowerOn_clicked();
	void on_pButton_PowerOff_clicked();
	void on_pButton_SetRobotModeRun_clicked();
	void on_pButton_SecurityStopRecover_clicked();
	void on_pButton_EmergencyStopRecover_clicked();
	void on_pButton_TeachMode_clicked();
	void on_pButton_TeachModeEnd_clicked();
	void on_pButton_Initialization_clicked();
	void on_pButton_Home_clicked();
	void on_pButton_Folder_clicked();
	void on_pButton_EnableFootSwitch_clicked();
	void on_pButton_DisableFootSwitch_clicked();
	void on_pButton_FootFix_clicked();
	void on_pButton_FootUp_clicked();
	void on_hSlider_Speed_valueChanged();
	void on_hSlider_Speed_sliderPressed();
	void on_hSlider_Speed_sliderReleased();
	void on_pButton_Stop_clicked();
	void on_pButton_Kin_clicked();
	void on_pButton_J0_Plus_pressed();
	void on_pButton_J0_Plus_released();
	void on_pButton_J0_Cut_pressed();
	void on_pButton_J0_Cut_released();
	void on_pButton_J1_Plus_pressed();
	void on_pButton_J1_Plus_released();
	void on_pButton_J1_Cut_pressed();
	void on_pButton_J1_Cut_released();
	void on_pButton_J2_Plus_pressed();
	void on_pButton_J2_Plus_released();
	void on_pButton_J2_Cut_pressed();
	void on_pButton_J2_Cut_released();
	void on_pButton_J3_Plus_pressed();
	void on_pButton_J3_Plus_released();
	void on_pButton_J3_Cut_pressed();
	void on_pButton_J3_Cut_released();
	void on_pButton_J4_Plus_pressed();
	void on_pButton_J4_Plus_released();
	void on_pButton_J4_Cut_pressed();
	void on_pButton_J4_Cut_released();
	void on_pButton_J5_Plus_pressed();
	void on_pButton_J5_Plus_released();
	void on_pButton_J5_Cut_pressed();
	void on_pButton_J5_Cut_released();
	void on_pButton_Xplus_pressed();
	void on_pButton_Xplus_released();
	void on_pButton_Xcut_pressed();
	void on_pButton_Xcut_released();
	void on_pButton_Yplus_pressed();
	void on_pButton_Yplus_released();
	void on_pButton_Ycut_pressed();
	void on_pButton_Ycut_released();
	void on_pButton_Zplus_pressed();
	void on_pButton_Zplus_released();
	void on_pButton_Zcut_pressed();
	void on_pButton_Zcut_released();
	void on_pButton_RXplus_pressed();
	void on_pButton_RXplus_released();
	void on_pButton_RXcut_pressed();
	void on_pButton_RXcut_released();
	void on_pButton_RYplus_pressed();
	void on_pButton_RYplus_released();
	void on_pButton_RYcut_pressed();
	void on_pButton_RYcut_released();
	void on_pButton_RZplus_pressed();
	void on_pButton_RZplus_released();
	void on_pButton_RZcut_pressed();
	void on_pButton_RZcut_released();

private:
    Ui::MainWindow *ui;
	RobotController *robotcontroller;
	bool speedSetFlag;
};

#endif // MAINWINDOW_H

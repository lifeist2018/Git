#include "mainwindow.h"
#include "ui_mainwindow.h"
#include <QString>
#include <QMessageBox>


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
	speedSetFlag = false;
    ui->setupUi(this);
	robotcontroller = RobotController::instance();
	this->ui->lineEdit_IP->setText("192.168.2.100");
	this->ui->lineEdit_Port->setText("30003");
	this->ui->radioButton_V18->setChecked(false);
	this->ui->radioButton_V30->setChecked(false);
	this->ui->radioButton_V32->setChecked(false);
	this->ui->radioButton_V35->setChecked(true);
	this->ui->radioButton_Base->setChecked(true);
	this->ui->radioButton_TCP->setChecked(false);

	QString stlPath = QApplication::applicationDirPath() + "/../.." + "/config" + "/RobotStl/";


	QString	m_ConfigFilePath = QApplication::applicationDirPath() + "/../.." + "/config" + "/2-02/" + "UR.txt";
	QString m_PostionDllPath = QApplication::applicationDirPath() + "/../.." + "/config" + "/Dll/" + "position.dll";
	m_ForceFilter=new ForceFilter();
	m_ForceCollectTimer=new QTimer();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::on_pButton_Connect_clicked()
{
	QString strIP = this->ui->lineEdit_IP->text();
	quint16 quitPort = this->ui->lineEdit_Port->text().toUShort();
	connect(robotcontroller, SIGNAL(OnConnect()),SLOT(on_robotcontroller_connect()));
	connect(robotcontroller, SIGNAL(OnDisconnect()),SLOT(on_robotcontroller_disconnect()));
	connect(robotcontroller, SIGNAL(OnReceiveData(const AsySocketClient::RobotState &)),SLOT(on_robotcontroller_ReceiveData(const AsySocketClient::RobotState &)));
	//connect(robotcontroller, SIGNAL(OnReceiveData(const AsySocketClient::RobotState &)),kinwin,SLOT(on_robotcontroller_ReceiveData(const AsySocketClient::RobotState &)));
	connect(robotcontroller, SIGNAL(OnNearToTarget()),SLOT(on_robotcontroller_neartotarget()));
	connect(robotcontroller, SIGNAL(OnRobotPowerOff()),SLOT(on_robotcontroller_poweroff()));
	connect(robotcontroller, SIGNAL(OnRobotIdle()),SLOT(on_robotcontroller_idle()));
	connect(robotcontroller, SIGNAL(OnRobotRun()),SLOT(on_robotcontroller_run()));
	connect(robotcontroller, SIGNAL(OnRobotExceedPositionLimit(bool)),SLOT(on_robotcontroller_exceedpositionlimit(bool)));
	connect(robotcontroller, SIGNAL(OnRobotNearToPositionLimit(bool)),SLOT(on_robotcontroller_neartopositionlimit(bool)));
	connect(robotcontroller, SIGNAL(OnOnRobotExceedSpeedLimit(bool)),SLOT(on_robotcontroller_exceedspeedlimit(bool)));
	connect(this->m_ForceCollectTimer, SIGNAL(timeout()), this, SLOT(slotForceCollectTimerDone()));

	if(this->ui->radioButton_V18->isChecked())
	{
		robotcontroller->SetRobotVersion(AsySocketClient::RobotVersion::V18);
	}
	else if(this->ui->radioButton_V30->isChecked())
	{
		robotcontroller->SetRobotVersion(AsySocketClient::RobotVersion::V30);
	}
	else if(this->ui->radioButton_V32->isChecked())
	{
		robotcontroller->SetRobotVersion(AsySocketClient::RobotVersion::V32);
	}
	else if(this->ui->radioButton_V35->isChecked())
	{
		robotcontroller->SetRobotVersion(AsySocketClient::RobotVersion::V35);
	}
	robotcontroller->SetJointSpeed(0.05);
	robotcontroller->SetJointAcceleration(0.05);
	robotcontroller->SetToolSpeed(0.05);
	robotcontroller->SetToolAcceleration(0.05);
	robotcontroller->Connect(strIP,quitPort);
}

void MainWindow::on_pButton_Disconnect_clicked()
{
	robotcontroller->Diconnect();
}

void MainWindow::on_robotcontroller_connect()
{
	this->ui->lineEdit_Status->setText("connect");
}

void MainWindow::on_robotcontroller_disconnect()
{
	this->ui->lineEdit_Status->setText("disconnect");
}

void MainWindow::on_robotcontroller_ReceiveData(const AsySocketClient::RobotState &robotState)
{
	//robot info
	this->ui->lineEdit_IsRobotConnected->setText(robotState.IsRobotConnected?"true":"false");
	this->ui->lineEdit_IsRealRobotEnabled->setText(robotState.IsRealRobotEnabled?"true":"false");
	this->ui->lineEdit_IsPowerOn->setText(robotState.IsPowerOnRobot?"true":"false");
	this->ui->lineEdit_IsEmergencyStopped->setText(robotState.IsEmergencyStopped?"true":"false");
	this->ui->lineEdit_IsSecurityStopped->setText(robotState.IsSecurityStopped?"true":"false");
	this->ui->lineEdit_IsProgramRunning->setText(robotState.IsProgramRunning?"true":"false");
	this->ui->lineEdit_IsProgramPaused->setText(robotState.IsProgramPaused?"true":"false");
	this->ui->lineEdit_RobotMode->setText(QString::number(robotState.RobotMode));
	//joint position info
	this->ui->lineEdit_J0->setText(QString::number(robotState.JointPosition[0]));
	this->ui->lineEdit_J1->setText(QString::number(robotState.JointPosition[1]));
	this->ui->lineEdit_J2->setText(QString::number(robotState.JointPosition[2]));
	this->ui->lineEdit_J3->setText(QString::number(robotState.JointPosition[3]));
	this->ui->lineEdit_J4->setText(QString::number(robotState.JointPosition[4]));
	this->ui->lineEdit_J5->setText(QString::number(robotState.JointPosition[5]));
	//joint speed info
	this->ui->lineEdit_J0_Speed->setText(QString::number(robotState.JointSpeed[0]));
	this->ui->lineEdit_J1_Speed->setText(QString::number(robotState.JointSpeed[1]));
	this->ui->lineEdit_J2_Speed->setText(QString::number(robotState.JointSpeed[2]));
	this->ui->lineEdit_J3_Speed->setText(QString::number(robotState.JointSpeed[3]));
	this->ui->lineEdit_J4_Speed->setText(QString::number(robotState.JointSpeed[4]));
	this->ui->lineEdit_J5_Speed->setText(QString::number(robotState.JointSpeed[5]));
	//Tool info
	this->ui->lineEdit_X->setText(QString::number(robotState.ToolPosition[0]*1000));
	this->ui->lineEdit_Y->setText(QString::number(robotState.ToolPosition[1]*1000));
	this->ui->lineEdit_Z->setText(QString::number(robotState.ToolPosition[2]*1000));
	this->ui->lineEdit_RX->setText(QString::number(robotState.ToolOrientation[0]));
	this->ui->lineEdit_RY->setText(QString::number(robotState.ToolOrientation[1]));
	this->ui->lineEdit_RZ->setText(QString::number(robotState.ToolOrientation[2]));
	//Digital info
	this->ui->checkBox_D0->setChecked(robotState.DigitalOut[0]);
	this->ui->checkBox_D1->setChecked(robotState.DigitalOut[1]);
	this->ui->checkBox_D2->setChecked(robotState.DigitalOut[2]);
	this->ui->checkBox_D3->setChecked(robotState.DigitalOut[3]);
	this->ui->checkBox_D4->setChecked(robotState.DigitalOut[4]);
	this->ui->checkBox_D5->setChecked(robotState.DigitalOut[5]);
	this->ui->checkBox_D6->setChecked(robotState.DigitalOut[6]);
	this->ui->checkBox_D7->setChecked(robotState.DigitalOut[7]);
	//this->ui->checkBox_TO0->setChecked(robotState.TO0);
	//this->ui->checkBox_TO1->setChecked(robotState.TO1);
	//this->ui->checkBox_TI0->setChecked(robotState.TI0);
	//this->ui->checkBox_TI1->setChecked(robotState.TI1);
	//speed
	//this->ui->hSlider_Speed->setValue(robotState.SpeedFraction*100);
	//this->ui->label_speed->setText(QString::number(robotState.SpeedFraction*100)+"%");
}

void MainWindow::on_robotcontroller_neartotarget()
{
	this->ui->lineEdit_Status->setText("neartotarget");
}

void MainWindow::on_robotcontroller_poweroff()
{
	this->ui->lineEdit_Status->setText("poweroff");
}

void MainWindow::on_robotcontroller_idle()
{
	this->ui->lineEdit_Status->setText("idle");
}

void MainWindow::on_robotcontroller_run()
{
	this->ui->lineEdit_Status->setText("run");
}

void MainWindow::on_robotcontroller_exceedpositionlimit(bool result)
{
	if(result)
	{
		this->ui->lineEdit_Status->setText(QString::fromLocal8Bit("位置超限"));
	}
	else
	{
		this->ui->lineEdit_Status->setText(QString::fromLocal8Bit("位置回到正常"));
	}
}

void MainWindow::on_robotcontroller_neartopositionlimit(bool result)
{
	if(result)
	{
		this->ui->lineEdit_Status->setText(QString::fromLocal8Bit("关节报警"));
	}
	else
	{
		this->ui->lineEdit_Status->setText(QString::fromLocal8Bit("报警回到正常"));
	}
}

void MainWindow::on_robotcontroller_exceedspeedlimit(bool result)
{
	if(result)
	{
		this->ui->lineEdit_Status->setText(QString::fromLocal8Bit("速度超限"));
	}
	else
	{
		this->ui->lineEdit_Status->setText(QString::fromLocal8Bit("速度回到正常"));
	}
}

void MainWindow::on_pButton_PowerOn_clicked()
{
	robotcontroller->PowerOn();
}

void MainWindow::on_pButton_PowerOff_clicked()
{
	robotcontroller->PowerOff();
}

void MainWindow::on_pButton_ShutDown_clicked()
{
	robotcontroller->ShutDown();
}

void MainWindow::on_pButton_SetRobotModeRun_clicked()
{
	robotcontroller->SetRobotmodeRun();
}

void MainWindow::on_pButton_SecurityStopRecover_clicked()
{
	robotcontroller->SecurityStopRecover();
}

void MainWindow::on_pButton_EmergencyStopRecover_clicked()
{
	robotcontroller->EmergencyStopRecover();
}

void MainWindow::on_pButton_TeachMode_clicked()
{
	robotcontroller->SetRobotTeachMode();
}

void MainWindow::on_pButton_TeachModeEnd_clicked()
{
	robotcontroller->SetRobotTeachModeEnd();
}

void MainWindow::on_pButton_Initialization_clicked()
{
	bool result = robotcontroller->Initialization();
	QMessageBox::about(this,"info",result?"true":"false");
}

void MainWindow::on_pButton_Home_clicked()
{
	robotcontroller->MoveToHome();
}

void MainWindow::on_pButton_Folder_clicked()
{
	robotcontroller->MoveToFolder();
}

void MainWindow::on_hSlider_Speed_valueChanged()
{
	if(speedSetFlag)
	{
		double speedVal = this->ui->hSlider_Speed->value();
		speedVal = speedVal / 100.0;
		robotcontroller->SetSpeed(speedVal);
	}
}

void MainWindow::on_hSlider_Speed_sliderPressed()
{
	speedSetFlag = true;
}

void MainWindow::on_hSlider_Speed_sliderReleased()
{
	speedSetFlag = false;
}

void MainWindow::on_pButton_Stop_clicked()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_Kin_clicked()
{

}

void MainWindow::on_pButton_OpenRobotModel_clicked()
{

}

void MainWindow::on_pButton_OpenRobotSimulate_clicked()
{

}

void MainWindow::on_pButton_OpenRobotControl_clicked()
{

}

void MainWindow::on_pButton_J0_Plus_pressed()
{
	robotcontroller->JointAdjust(0,1);
}
void MainWindow::on_pButton_J0_Plus_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J0_Cut_pressed()
{
	robotcontroller->JointAdjust(0,-1);
}
void MainWindow::on_pButton_J0_Cut_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J1_Plus_pressed()
{
	robotcontroller->JointAdjust(1,1);
}
void MainWindow::on_pButton_J1_Plus_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J1_Cut_pressed()
{
	robotcontroller->JointAdjust(1,-1);
}
void MainWindow::on_pButton_J1_Cut_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J2_Plus_pressed()
{
	robotcontroller->JointAdjust(2,1);
}
void MainWindow::on_pButton_J2_Plus_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J2_Cut_pressed()
{
	robotcontroller->JointAdjust(2,-1);
}
void MainWindow::on_pButton_J2_Cut_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J3_Plus_pressed()
{
	robotcontroller->JointAdjust(3,1);
}
void MainWindow::on_pButton_J3_Plus_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J3_Cut_pressed()
{
	robotcontroller->JointAdjust(3,-1);
}
void MainWindow::on_pButton_J3_Cut_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J4_Plus_pressed()
{
	robotcontroller->JointAdjust(4,1);
}
void MainWindow::on_pButton_J4_Plus_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J4_Cut_pressed()
{
	robotcontroller->JointAdjust(4,-1);
}
void MainWindow::on_pButton_J4_Cut_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J5_Plus_pressed()
{
	robotcontroller->JointAdjust(5,1);
}
void MainWindow::on_pButton_J5_Plus_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_J5_Cut_pressed()
{
	robotcontroller->JointAdjust(5,-1);
}
void MainWindow::on_pButton_J5_Cut_released()
{
	robotcontroller->Stopj();
}

void MainWindow::on_pButton_Xplus_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::x,1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::x,1);
	}
}
void MainWindow::on_pButton_Xplus_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_Xcut_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::x,-1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::x,-1);
	}
}
void MainWindow::on_pButton_Xcut_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_Yplus_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::y,1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::y,1);
	}
}
void MainWindow::on_pButton_Yplus_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_Ycut_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::y,-1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::y,-1);
	}
}
void MainWindow::on_pButton_Ycut_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_Zplus_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::z,1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::z,1);
	}
}
void MainWindow::on_pButton_Zplus_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_Zcut_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::z,-1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::z,-1);
	}
}
void MainWindow::on_pButton_Zcut_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_RXplus_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::rx,1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::rx,1);
	}
}
void MainWindow::on_pButton_RXplus_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_RXcut_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::rx,-1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::rx,-1);
	}
}
void MainWindow::on_pButton_RXcut_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_RYplus_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::ry,1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::ry,1);
	}
}
void MainWindow::on_pButton_RYplus_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_RYcut_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::ry,-1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::ry,-1);
	}
}
void MainWindow::on_pButton_RYcut_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_RZplus_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::rz,1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::rz,1);
	}
}
void MainWindow::on_pButton_RZplus_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_RZcut_pressed()
{
	if(this->ui->radioButton_Base->isChecked())
	{
		robotcontroller->CartesianAdjustBase(RobotController::PoseEnum::rz,-1);
	}
	else
	{
		robotcontroller->CartesianAdjustTcp(RobotController::PoseEnum::rz,-1);
	}
}
void MainWindow::on_pButton_RZcut_released()
{
	robotcontroller->Stopl();
}

void MainWindow::on_pButton_EnableFootSwitch_clicked()
{
	robotcontroller->EnableFootSwitch();
}
void MainWindow::on_pButton_DisableFootSwitch_clicked()
{
	robotcontroller->DisableFootSwitch();
}
void MainWindow::on_pButton_FootFix_clicked()
{
	robotcontroller->FootFix();
}
void MainWindow::on_pButton_FootUp_clicked()
{
	robotcontroller->FootUp();
}

void MainWindow::slotForceCollectTimerDone()
{
	double force[6];
	this->m_ForceFilter->GetForce(force);
	this->SetList(this->m_Force,force);
}

void  MainWindow::SetList(vector<vector<double>> &list,double data[6])
{
	vector<double> element;
	for(int i=0;i<sizeof(data);i++)
	{
		element.push_back(data[i]);
	}
	list.push_back(element);
}


void MainWindow::OutputFile()
{
	if(m_Force.size()!=0)
	{
		WriteInfo(m_Force,"force");
	}
}

void MainWindow::WriteInfo(std::vector<std::vector<double>> infoList,QString name)
{
	QString tcpData;
	tcpData.append("X  Y  Z  RX  RY  RZ  \n");
	for(int i=0;i<infoList.size();i++)
	{
		tcpData.append(QString("%1  %2  %3  %4  %5  %6\n").arg
							(QString::number(floor(infoList[i][0]*100.00f+0.5)/100.00f),
							QString::number(floor(infoList[i][1]*100.00f+0.5)/100.00f),
							QString::number(floor(infoList[i][2]*100.00f+0.5)/100.00f),
							QString::number(floor(infoList[i][3]*100.00f+0.5)/100.00f),
							QString::number(floor(infoList[i][4]*100.00f+0.5)/100.00f),
							QString::number(floor(infoList[i][5]*100.00f+0.5)/100.00f)));
	}
	tcpData.append("end\n");

	//QString current_date = GetCurrentDateTime();
	QString path;
	path="D://"+name+".txt";
	//current_date.append("-Force.txt");
	//std::cout<<path.toStdString()<<endl;
	//string str=current_date.toStdString();
    QFile file(path);  
    file.open(QIODevice::ReadWrite | QIODevice::Text);
  
	file.write(tcpData.toUtf8());
	file.flush();
    file.close();
}

void MainWindow::on_pButton_StartCollect_clicked()
{
	if(m_Force.size()!=0)
	{
		m_Force.clear();
	}
	this->m_ForceCollectTimer->start(40);
}

void MainWindow::on_pButton_EndCollect_clicked()
{
	this->OutputFile();
	this->m_ForceCollectTimer->stop();
}
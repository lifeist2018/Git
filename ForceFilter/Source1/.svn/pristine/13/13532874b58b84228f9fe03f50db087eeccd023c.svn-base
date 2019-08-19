#include "RobotController.h"
#include <QThread>
#include <QtGui>
//#include "modbus.h"
#include <iostream>

RobotController *RobotController::m_instance = 0;
RobotController::RobotController(QObject *parent) : QObject(parent)
{
	m_D0 = 0;
    m_D1 = 0;
    m_D2 = 0;

	m_jointPositionLimitMax = 330;
	m_jointPositionLimitMin = -330;
	m_jointNearToPositionLimitMax = 250;
	m_jointNearToPositionLimitMin = -250;
	m_jointSpeedLimitMax = 170;
	m_jointSpeedLimitMin = -170;
	m_callNearToLimitStatus = "None"; 
	m_callPositionLimitStatus = "None";
	m_callSpeedLimitStatus = "None";

	m_previousrobotState = RobotState::none;

	m_targetPoseEnable = false;
	m_targetJointEnable = false;
	memset(targetJoint,0,sizeof(targetJoint));
	memset(targetPose,0,sizeof(targetPose));
	m_jointSpeed = 0.1;
	m_jointAcceleration = 0.5;
	m_toolSpeed = 0.1;
	m_toolAcceleration = 0.5;
	asySocket = new AsySocketClient();

	connect(asySocket, SIGNAL(OnConnect()),SLOT(socketConnected())); 
	connect(asySocket, SIGNAL(OnDisconnect()),SLOT(socketDisconnected())); 
	connect(asySocket, SIGNAL(OnDataBlocking()),SLOT(socketDataBlocking())); 
	connect(asySocket, SIGNAL(OnReceiveData(const AsySocketClient::RobotState &)),SLOT(socketReceiveData(const AsySocketClient::RobotState &)));
	connect(this, SIGNAL(OnRobotExceedPositionLimit(bool)),this,SLOT(slotExceedPositionLimit(bool))); 
	connect(this, SIGNAL(OnOnRobotExceedSpeedLimit(bool)),this,SLOT(slotExceedSpeedLimit(bool))); 
	connect(this, SIGNAL(OnRobotNearToPositionLimit(bool)),this,SLOT(slotNearToPositionLimit(bool))); 
	connect(this, SIGNAL(OnConnect()),this,SLOT(slotConnect())); 
	memset(m_TcpForce,0,sizeof(m_TcpForce));
	memset(m_TcpForceBais,0,sizeof(m_TcpForceBais));
}

RobotController::~RobotController()
{

}

void RobotController::Connect(QString ipAddress,quint16 port)
{
	m_ipAddress = ipAddress;
	asySocket->TimeOutConnect(ipAddress,port);
}

void RobotController::Diconnect()
{
	asySocket->Disconnect();
}

void RobotController::SetRobotVersion(AsySocketClient::RobotVersion myVersion)
{
	asySocket->SetRobotVersion(myVersion);
}

void RobotController::SetJointSpeed(double mySpeed)
{
	m_jointSpeed = mySpeed;
}

void RobotController::SetJointAcceleration(double myAcceleration)
{
	m_jointAcceleration = myAcceleration;
}

void RobotController::SetToolSpeed(double mySpeed)
{
	m_toolSpeed = mySpeed;
}

void RobotController::SetToolAcceleration(double myAcceleration)
{
	m_toolAcceleration = myAcceleration;
}

void RobotController::socketConnected()
{
	emit OnConnect();
}

void RobotController::socketDisconnected()
{
	emit OnDisconnect();
}

void RobotController::socketDataBlocking()
{
	emit OnDataBlocking();
}

void RobotController::socketReceiveData(const AsySocketClient::RobotState &robotState)
{
	emit OnReceiveData(robotState);

	if (m_targetPoseEnable == true)
	{
		if (NearToPose(targetPose))
		{
			emit OnNearToTarget();
			m_targetPoseEnable = false;
			m_targetJointEnable = false;
		}
	}
	if (m_targetJointEnable == true)
	{
		if (NearToJoint(targetJoint))
		{
			emit OnNearToTarget();
			m_targetPoseEnable = false;
			m_targetJointEnable = false;
		}
	}

	if (asySocket->robotVersion == AsySocketClient::RobotVersion::V30)
	{
		if (asySocket->robotState.RobotMode == 3 && m_previousrobotState != RobotState::poweroff)
		{
			emit OnRobotPowerOff();
			m_previousrobotState = RobotState::poweroff;
		}
		else if (asySocket->robotState.RobotMode == 5 && m_previousrobotState != RobotState::idle)
		{
			emit OnRobotIdle();
			m_previousrobotState = RobotState::idle;
		}
		else if (asySocket->robotState.RobotMode == 7 && m_previousrobotState != RobotState::run)
		{
			emit OnRobotRun();
			m_previousrobotState = RobotState::run;
		}
	}

	if (asySocket->robotState.JointPosition[0] >= m_jointNearToPositionLimitMax || asySocket->robotState.JointPosition[0] <= m_jointNearToPositionLimitMin ||
        asySocket->robotState.JointPosition[1] >= m_jointNearToPositionLimitMax || asySocket->robotState.JointPosition[1] <= m_jointNearToPositionLimitMin ||
        asySocket->robotState.JointPosition[2] >= m_jointNearToPositionLimitMax || asySocket->robotState.JointPosition[2] <= m_jointNearToPositionLimitMin ||
        asySocket->robotState.JointPosition[3] >= m_jointNearToPositionLimitMax || asySocket->robotState.JointPosition[3] <= m_jointNearToPositionLimitMin ||
        asySocket->robotState.JointPosition[4] >= m_jointNearToPositionLimitMax || asySocket->robotState.JointPosition[4] <= m_jointNearToPositionLimitMin ||
        asySocket->robotState.JointPosition[5] >= m_jointNearToPositionLimitMax || asySocket->robotState.JointPosition[5] <= m_jointNearToPositionLimitMin)
        {
            if (m_callNearToLimitStatus == "None" || m_callNearToLimitStatus == "Normal")
            {
				emit OnRobotNearToPositionLimit(true);
                m_callNearToLimitStatus = "NearToLimit";
            }
        }
        else
        {
            if (m_callNearToLimitStatus == "NearToLimit")
            {
                emit OnRobotNearToPositionLimit(false);
                m_callNearToLimitStatus = "Normal";
            }
        }
	if (asySocket->robotState.JointPosition[0] >= m_jointPositionLimitMax || asySocket->robotState.JointPosition[0] <= m_jointPositionLimitMin ||
        asySocket->robotState.JointPosition[1] >= m_jointPositionLimitMax || asySocket->robotState.JointPosition[1] <= m_jointPositionLimitMin ||
        asySocket->robotState.JointPosition[2] >= m_jointPositionLimitMax || asySocket->robotState.JointPosition[2] <= m_jointPositionLimitMin ||
        asySocket->robotState.JointPosition[3] >= m_jointPositionLimitMax || asySocket->robotState.JointPosition[3] <= m_jointPositionLimitMin ||
        asySocket->robotState.JointPosition[4] >= m_jointPositionLimitMax || asySocket->robotState.JointPosition[4] <= m_jointPositionLimitMin ||
        asySocket->robotState.JointPosition[5] >= m_jointPositionLimitMax || asySocket->robotState.JointPosition[5] <= m_jointPositionLimitMin)
        {
            if (m_callPositionLimitStatus == "None" || m_callPositionLimitStatus == "Normal")
            {
                emit OnRobotExceedPositionLimit(true);
                m_callPositionLimitStatus = "Exceed";
            }
        }
        else
        {
            if (m_callPositionLimitStatus == "Exceed")
            {
                emit OnRobotExceedPositionLimit(false);
                m_callPositionLimitStatus = "Normal";
            }
        }

    if (asySocket->robotState.JointSpeed[0] >= m_jointSpeedLimitMax || asySocket->robotState.JointSpeed[1] <= m_jointSpeedLimitMin ||
		asySocket->robotState.JointSpeed[1] >= m_jointSpeedLimitMax || asySocket->robotState.JointSpeed[1] <= m_jointSpeedLimitMin ||
		asySocket->robotState.JointSpeed[2] >= m_jointSpeedLimitMax || asySocket->robotState.JointSpeed[2] <= m_jointSpeedLimitMin ||
		asySocket->robotState.JointSpeed[3] >= m_jointSpeedLimitMax || asySocket->robotState.JointSpeed[3] <= m_jointSpeedLimitMin ||
		asySocket->robotState.JointSpeed[4] >= m_jointSpeedLimitMax || asySocket->robotState.JointSpeed[4] <= m_jointSpeedLimitMin ||
		asySocket->robotState.JointSpeed[5] >= m_jointSpeedLimitMax || asySocket->robotState.JointSpeed[5] <= m_jointSpeedLimitMin)
            {
				//if (asySocket->robotState.DigitalOut[2] == false)
				//{
					////关节速度已经超限，但是还未停止示教，需要抛出事件
					//emit OnOnRobotExceedSpeedLimit(true);
				 //}
				if (m_callSpeedLimitStatus == "None" || m_callSpeedLimitStatus == "Normal")
				{
					emit OnOnRobotExceedSpeedLimit(true);
					m_callSpeedLimitStatus = "Exceed";
				}
            }
            else
            {
                //if (asySocket->robotState.DigitalOut[2] == true)
                //{
                    ////关节速度恢复正常，但是启用示教，需要抛出事件
					//emit OnOnRobotExceedSpeedLimit(false);
                //}
				if (m_callSpeedLimitStatus == "Exceed")
				{
					emit OnOnRobotExceedSpeedLimit(false);
					m_callSpeedLimitStatus = "Normal";
				}
            }
}

bool RobotController::NearToPose(double *targetPose)
{
	double currentPose[6];
	currentPose[0] = asySocket->robotState.ToolPosition[0];
	currentPose[1] = asySocket->robotState.ToolPosition[1];
	currentPose[2] = asySocket->robotState.ToolPosition[2];
	currentPose[3] = asySocket->robotState.ToolOrientation[0];
	currentPose[4] = asySocket->robotState.ToolOrientation[1];
	currentPose[5] = asySocket->robotState.ToolOrientation[2];

	QVector3D pTarget = QVector3D(targetPose[0], targetPose[1], targetPose[2]);
	QVector3D rTarget = QVector3D(targetPose[3], targetPose[4], targetPose[5]);
	QVector3D pCurrent = QVector3D(currentPose[0], currentPose[1], currentPose[2]);
	QVector3D rCurrent = QVector3D(currentPose[3], currentPose[4], currentPose[5]);

	pTarget -= pCurrent;

	float angleTarget = rTarget.length();
	if (angleTarget != 0.0)
	{
		rTarget.normalize();
	}
	else
	{
		rTarget.setX(0);
		rTarget.setY(0);
		rTarget.setZ(1);
	}

	float angleCurrent = rCurrent.length();
	if (angleCurrent != 0.0)
	{
		rCurrent.normalize();
	}
	else
	{
		rCurrent.setX(0);
		rCurrent.setY(0);
		rCurrent.setZ(1);
	}

	QQuaternion q3dTarget = QQuaternion::fromAxisAndAngle(rTarget, angleTarget*180/PI);
	QQuaternion q3dCurrent = QQuaternion::fromAxisAndAngle(rCurrent, angleCurrent*180/PI);

	q3dCurrent.inverted();
	q3dTarget *= q3dCurrent;

	q3dTarget.getAxisAndAngle(&rTarget,&angleTarget);

	///////////////////
	if (angleTarget > 3.141592653589793)
	{
		angleTarget -= 6.283185307179586;
	}
	if (angleTarget < -3.141592653589793)
	{
		angleTarget += 6.283185307179586;
	}
	///////////////////

	double result = pTarget.length() + 0.1 * abs(angleTarget);

	if (result < 0.02)
	{
		return true;
	}
	else
	{
		return false;
	}
}

bool RobotController::NearToJoint(double *targetJoint)
{
	double currentJoint[6];
	currentJoint[0] = asySocket->robotState.JointPosition[0];
	currentJoint[1] = asySocket->robotState.JointPosition[1];
	currentJoint[2] = asySocket->robotState.JointPosition[2];
	currentJoint[3] = asySocket->robotState.JointPosition[0];
	currentJoint[4] = asySocket->robotState.JointPosition[1];
	currentJoint[5] = asySocket->robotState.JointPosition[2];

	for (int i = 0; i < 6; i++)
	{
		if (abs(currentJoint[i] - targetJoint[i]) > 0.02)
		{
			return false;
		}
	}

	return true;
}

void RobotController::PowerOn()
{
	QString cmd = "power on\n";
	asySocket->SendStream(cmd);
}

void RobotController::PowerOff()
{
	QString cmd = "power off\n";
	asySocket->SendStream(cmd);
}

void RobotController::ShutDown()
{
	QString cmd = "powerdown()\n";
	asySocket->SendStream(cmd);
}

void RobotController::SetRobotmodeRun()
{
	QString cmd = "set robotmode run\n";
	asySocket->SendStream(cmd);
}

void RobotController::SetFreedrive()
{
	QString cmd = "set robotmode freedrive\n";
	asySocket->SendStream(cmd);
}

void RobotController::SetUnlockProtectiveStop()
{
	QString cmd = "set unlock protective stop\n";
	asySocket->SendStream(cmd);
}

void RobotController::EmergencyStopRecover()
{
	if(asySocket->robotVersion == AsySocketClient::RobotVersion::V18)
	{
		PowerOn();
	}
	else
	{
		//要先上电再解锁
		PowerOn();
		QThread::msleep(3500);
		SetRobotmodeRun();
	}
}

void RobotController::SecurityStopRecover()
{
	if(asySocket->robotVersion == AsySocketClient::RobotVersion::V18)
	{
		SetRobotmodeRun();
	}
	else
	{
		SetUnlockProtectiveStop();
	}
}

void RobotController::StartTeachMode()
{
	QString cmd;
	cmd.append("def teachmode():\n");
	cmd.append(" teach_mode()\n");
	cmd.append(" sleep(3600)\n");
	cmd.append("end\n");
	asySocket->SendStream(cmd);
}

void RobotController::EndTeachMode()
{
	QString cmd;
	cmd.append("def teachmodeend():\n");
	cmd.append(" end_teach_mode()\n");
	cmd.append("end\n");
	asySocket->SendStream(cmd);
}

void RobotController::SetRobotTeachMode()
{
	if(asySocket->robotVersion == AsySocketClient::RobotVersion::V18)
	{
		SetFreedrive();
	}
	else
	{
		StartTeachMode();
	}
}

void RobotController::SetRobotTeachModeEnd()
{
	if(asySocket->robotVersion == AsySocketClient::RobotVersion::V18)
	{
		SetRobotmodeRun();
	}
	else
	{
		EndTeachMode();
	}
}

//bool RobotController::Initialization()
//{
//	QThread::msleep(500);
//	if(asySocket->robotVersion == AsySocketClient::RobotVersion::V18)
//	{
//		//V18
//		if(asySocket->robotState.RobotMode == 0)
//		{
//			return true;
//		}
//		else
//		{
//			return false;
//		}
//	}
//	else
//	{
//		//V30
//		if(asySocket->robotState.RobotMode == 7)
//		{
//			return true;
//		}
//		else if(asySocket->robotState.RobotMode == 5)
//		{
//			//Idle
//			SetRobotmodeRun();
//			int counts = 0;
//			while (asySocket->robotState.RobotMode != 7 && counts < 30)
//			{
//				QThread::msleep(500);
//				counts++;
//			}
//			if (counts == 30)
//			{
//				//超时返回
//				return false;
//			}
//			else
//			{
//				SetUnlockProtectiveStop();
//				//初始化完成返回
//				return true;
//			}
//		}
//		else if(asySocket->robotState.RobotMode == 3)
//		{
//			//PowerOff
//			PowerOn();
//			int counts = 0;
//			while (asySocket->robotState.RobotMode != 5 && counts < 30)
//			{
//				QThread::msleep(500);
//				counts++;
//			}
//			if (counts == 30)
//			{
//				//超时返回
//				return false;
//			}
//			else
//			{
//				SetRobotmodeRun();
//				int counts = 0;
//				while (asySocket->robotState.RobotMode != 7 && counts < 30)
//				{
//					QThread::msleep(500);
//					counts++;
//				}
//				if (counts == 30)
//				{
//					//超时返回
//					return false;
//				}
//				else
//				{
//					SetUnlockProtectiveStop();
//					//初始化完成返回
//					return true;
//				}
//			}
//		}
//		else
//		{
//			return false;
//		}
//	}
//}

bool RobotController::Initialization()
{
	//QThread::msleep(500);
	if(asySocket->robotVersion == AsySocketClient::RobotVersion::V18)
	{
		//V18
		if(asySocket->robotState.RobotMode == 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		//V30
		if(asySocket->robotState.RobotMode == 7)
		{
			return true;
		}
		else if(asySocket->robotState.RobotMode == 5)
		{
			//Idle
			SetRobotmodeRun();
			SetUnlockProtectiveStop();
			return true;
		}
		else if(asySocket->robotState.RobotMode == 3)
		{
			//PowerOff
			PowerOn();
			SetRobotmodeRun();
			SetUnlockProtectiveStop();
			return true;
		}
		else
		{
			return false;
		}
	}
}

void RobotController::JointAdjust(int jointNum, int adjust)
{
	double joint0, joint1, joint2, joint3, joint4, joint5;
	joint0 = asySocket->robotState.JointPosition[0];
	joint1 = asySocket->robotState.JointPosition[1];
	joint2 = asySocket->robotState.JointPosition[2];
	joint3 = asySocket->robotState.JointPosition[3];
	joint4 = asySocket->robotState.JointPosition[4];
	joint5 = asySocket->robotState.JointPosition[5];

	joint0 = (joint0 * PI) / 180;
	joint1 = (joint1 * PI) / 180;
	joint2 = (joint2 * PI) / 180;
	joint3 = (joint3 * PI) / 180;
	joint4 = (joint4 * PI) / 180;
	joint5 = (joint5 * PI) / 180;

	double step = 0;
	if (adjust == 1)
	{
		step = (360 * PI) / 180;
	}
	else if (adjust == -1)
	{
		step = -(360 * PI) / 180;
	}

	switch (jointNum)
	{
	case 0:
		joint0 = step;
		break;
	case 1:
		joint1 = step;
		break;
	case 2:
		joint2 = step;
		break;
	case 3:
		joint3 = step;
		break;
	case 4:
		joint4 = step;
		break;
	case 5:
		joint5 = step;
		break;
	}

	QString cmd = QString("movej([%1,%2,%3,%4,%5,%6], a=%7, v=%8)\n").arg
		(QString::number(joint0),QString::number(joint1),
		QString::number(joint2),QString::number(joint3),
		QString::number(joint4),QString::number(joint5),
		QString::number(m_jointAcceleration),QString::number(m_jointSpeed));

	asySocket->SendStream(cmd);
}

void RobotController::CartesianAdjustBase(PoseEnum myPose, int adjust)
{
	QVector3D translate = QVector3D(0.0f,0.0f,0.0f);
	QVector3D rotate = QVector3D(0.0f,0.0f,0.0f);

	switch (myPose)
	{
		case PoseEnum::x:
			if (adjust == 1)
			{
				translate.setX(0.05f);
			}
			else if (adjust == -1)
			{
				translate.setX(-0.05f);
			}
			break;
		case PoseEnum::y:
			if (adjust == 1)
			{
				translate.setY(0.05f);
			}
			else if (adjust == -1)
			{
				translate.setY(-0.05f);
			}
			break;
		case PoseEnum::z:
			if (adjust == 1)
			{
				translate.setZ(0.05f);
			}
			else if (adjust == -1)
			{
				translate.setZ(-0.05f);
			}
			break;
		case PoseEnum::rx:
			if (adjust == 1)
			{
				rotate.setX(0.2f);
			}
			else if (adjust == -1)
			{
				rotate.setX(-0.2f);
			}
			break;
		case PoseEnum::ry:
			if (adjust == 1)
			{
				rotate.setY(0.2f);
			}
			else if (adjust == -1)
			{
				rotate.setY(-0.2f);
			}
			break;
		case PoseEnum::rz:
			if (adjust == 1)
			{
				rotate.setZ(0.2f);
			}
			else if (adjust == -1)
			{
				rotate.setZ(-0.2f);
			}
			break;
	}

	QString cmd = QString("speedl([%1,%2,%3,%4,%5,%6],1.2,100.0)\n").arg
		(QString::number(translate.x()),QString::number(translate.y()),
		QString::number(translate.z()),QString::number(rotate.x()),
		QString::number(rotate.y()),QString::number(rotate.z()));

	asySocket->SendStream(cmd);
}

void RobotController::CartesianAdjustTcp(PoseEnum myPose, int adjust)
{
	QVector3D translate = QVector3D(0.0f,0.0f,0.0f);
	QVector3D rotate = QVector3D(0.0f,0.0f,0.0f);
	QVector3D v = QVector3D(asySocket->robotState.ToolPosition[0],asySocket->robotState.ToolPosition[1],asySocket->robotState.ToolPosition[2]);
	QVector3D r = QVector3D(asySocket->robotState.ToolOrientation[0],asySocket->robotState.ToolOrientation[1],asySocket->robotState.ToolOrientation[2]);
	QMatrix4x4 m;
	m = GetMatrixFromRotateVector(v,r);

	switch (myPose)
	{
		case PoseEnum::x:
			if (adjust == 1)
			{
				translate.setX(1.0f);
			}
			else if (adjust == -1)
			{
				translate.setX(-1.0f);
			}
			break;
		case PoseEnum::y:
			if (adjust == 1)
			{
				translate.setY(1.0f);
			}
			else if (adjust == -1)
			{
				translate.setY(-1.0f);
			}
			break;
		case PoseEnum::z:
			if (adjust == 1)
			{
				translate.setZ(1.0f);
			}
			else if (adjust == -1)
			{
				translate.setZ(-1.0f);
			}
			break;
		case PoseEnum::rx:
			if (adjust == 1)
			{
				rotate.setX(1.0f);
			}
			else if (adjust == -1)
			{
				rotate.setX(-1.0f);
			}
			break;
		case PoseEnum::ry:
			if (adjust == 1)
			{
				rotate.setY(1.0f);
			}
			else if (adjust == -1)
			{
				rotate.setY(-1.0f);
			}
			break;
		case PoseEnum::rz:
			if (adjust == 1)
			{
				rotate.setZ(1.0f);
			}
			else if (adjust == -1)
			{
				rotate.setZ(-1.0f);
			}
			break;
	}

	translate = m.mapVector(translate);
	rotate = m.mapVector(rotate);

	translate = translate * 0.05f;
	rotate = rotate * 0.2f;

	QString cmd = QString("speedl([%1,%2,%3,%4,%5,%6],1.2,100.0)\n").arg
		(QString::number(translate.x()),QString::number(translate.y()),
		QString::number(translate.z()),QString::number(rotate.x()),
		QString::number(rotate.y()),QString::number(rotate.z()));

	asySocket->SendStream(cmd);
}

QMatrix4x4 RobotController::GetMatrixFromRotateVector(QVector3D t,QVector3D r)
{
	double l = r.length();
	r.normalize();
	QQuaternion  q = QQuaternion::fromAxisAndAngle(r,l * 180 / PI);
	QMatrix4x4 m;
	m.setToIdentity();
	m.translate(t);
	m.rotate(q);
	return m;
}

void RobotController::Stopj()
{
	QString cmd = "stopj(2.0)\n";
	asySocket->SendStream(cmd);
}

void RobotController::Stopl()
{
	QString cmd = "stopl(2.0)\n";
	asySocket->SendStream(cmd);
}

void RobotController::MoveTo(double* posePointer)
{
	double X = posePointer[0];
	double Y = posePointer[1];
	double Z = posePointer[2];
	double RX = posePointer[3];
	double RY = posePointer[4];
	double RZ = posePointer[5];

	memcpy(targetPose,posePointer,sizeof(targetPose));
	m_targetPoseEnable = true;
	m_targetJointEnable = false;

	QString cmd = QString("movel(p[%1,%2,%3,%4,%5,%6], a=%7, v=%8)\n").arg
		(QString::number(X),QString::number(Y),
		QString::number(Z),QString::number(RX),
		QString::number(RY),QString::number(RZ),
		QString::number(m_toolAcceleration),QString::number(m_toolSpeed));

	asySocket->SendStream(cmd);
}

void RobotController::MoveJointTo(double* jointPointer)
{
	
}

void RobotController::MoveToHome()
{
	double jointValue[6];
	for(int i=0;i<6;i++)
	{
		jointValue[i] = ConstJointHome[i];
	}
	MoveJointTo(jointValue);
}

void RobotController::MoveToFolder()
{
	double jointValue[6];
	for(int i=0;i<6;i++)
	{
		jointValue[i] = ConstJointFolder[i];
	}
	MoveJointTo(jointValue);
}

void RobotController::SetSpeed(double speedVal)
{
	QString cmd = QString("set speed %1\n").arg
		(QString::number(speedVal,'d',2));

	asySocket->SendStream(cmd);
}

void RobotController::GetKin(double* joint,double* pose)
{

}

bool RobotController::GetInverseKin(double* pose,double* joint,double* jointRefer)
{
	return true;
}

bool RobotController::IfHaveInverseKin(double* pose)
{
	return true;
}

void RobotController::MoveRobotToPlanPose(double* pose)
{
	
}

void RobotController::MoveRobotToPlanPose(double* pose,double* jointRefer)
{
	
}

void RobotController::MoveRobotToTrajectory(double* pose)
{
	
}

void RobotController::MoveRobotTcpToTrajectory(double* pose)
{
	
}


void RobotController::Movep(double* pose)
{
	
}

void RobotController::MoveWaypoint(double* pose)//movep(joint);
{
	
}

void RobotController::MoveWaypoint(double* pose,double home[6])//movep(joint);
{

}

void RobotController::Servoc(double* pose,double a,double v,double rsdius)
{
	
}

void RobotController::Servoj(double* pose,double t, double lookaheadt, double gain)
{
	
}

void RobotController::SetTcp(double* pose)
{
	
}

void RobotController::Speedl(double* xd,double a,double min)
{
	double x = xd[0];
	double y = xd[1];
	double z = xd[2];
	double rx = xd[3];
	double ry = xd[4];
	double rz = xd[5];

	QString cmd = QString("speedl([%1,%2,%3,%4,%5,%6], %7, %8)\n").arg
	//QString cmd = QString("speedj([-0.2,0.0,0.0,0.0,0.0,0.0], 0.3, 100)\n"); //.arg
		(QString::number(x),QString::number(y),
		QString::number(z),QString::number(rx),
		QString::number(ry),QString::number(rz),
		QString::number(a),QString::number(min));
	/*cout<<"speedl： "<<cmd.toStdString()<<endl;*/
	asySocket->SendStream(cmd);
}

void RobotController::Speedj(double* xd,double a,double min)
{
	double x = xd[0]/1000;
	double y = xd[1]/1000;
	double z = xd[2]/1000;
	double rx = xd[3];
	double ry = xd[4];
	double rz = xd[5];

	//QString cmd = QString("servoc(p[%1,%2,%3,%4,%5,%6], %7, %8)\n").arg
	QString cmd = QString("speedj([-0.2,0.0,0.0,0.0,0.0,0.0], 0.3, 100)\n"); //.arg
		(QString::number(x),QString::number(y),
		QString::number(z),QString::number(rx),
		QString::number(ry),QString::number(rz),
		QString::number(a),QString::number(min));
	//cout<<cmd.toStdString()<<endl;
	asySocket->SendStream(cmd);
}

bool RobotController::ChooseJointSolution(double *poseIn,double *jointRadResult,double *jointRadRefer)//jointRadRefer是弧度
{
	return true;
}

void RobotController::FootFix()
{
	
}

void RobotController::FootUp()
{
	
}

void RobotController::EnableFootSwitch()
{
	
}

void RobotController::DisableFootSwitch()
{
	
}

void RobotController::slotExceedPositionLimit(bool result)
{
	if(result)
	{
		DisableFootSwitch();
	}
	else
	{
		EnableFootSwitch();
	}
}

void RobotController::slotExceedSpeedLimit(bool result)
{
	if(result)
	{
		DisableFootSwitch();
	}
	else
	{
		EnableFootSwitch();
	}
}

void RobotController::slotNearToPositionLimit(bool result)
{
	if(result)
	{

	}
	else
	{

	}
}

void RobotController::slotConnect()
{
	Initialization();
}

void RobotController::GetCurrentPose(double* pose)
{
	pose[0] = asySocket->robotState.ToolPosition[0];
	pose[1] = asySocket->robotState.ToolPosition[1];
	pose[2] = asySocket->robotState.ToolPosition[2];
	pose[3] = asySocket->robotState.ToolOrientation[0];
	pose[4] = asySocket->robotState.ToolOrientation[1];
	pose[5] = asySocket->robotState.ToolOrientation[2];

	pose[0] = pose[0] * 1000;
	pose[1] = pose[1] * 1000;
	pose[2] = pose[2] * 1000;
}

void RobotController::GetCurrentJoint(double* joint)
{
	joint[0] = asySocket->robotState.JointPosition[0];
	joint[1] = asySocket->robotState.JointPosition[1];
	joint[2] = asySocket->robotState.JointPosition[2];
	joint[3] = asySocket->robotState.JointPosition[3];
	joint[4] = asySocket->robotState.JointPosition[4];
	joint[5] = asySocket->robotState.JointPosition[5];
}

void RobotController::GetCurrentJointSpeed(double* jointSpeed)
{
	jointSpeed[0] = asySocket->robotState.JointSpeed[0];
	jointSpeed[1] = asySocket->robotState.JointSpeed[1];
	jointSpeed[2] = asySocket->robotState.JointSpeed[2];
	jointSpeed[3] = asySocket->robotState.JointSpeed[3];
	jointSpeed[4] = asySocket->robotState.JointSpeed[4];
	jointSpeed[5] = asySocket->robotState.JointSpeed[5];
}

double RobotController::GetRobotSecurityState()
{
	if(this->asySocket->robotState.IsEmergencyStopped)
		return 0;
	if(this->asySocket->robotState.IsSecurityStopped)
		return 1;
	return 2;
}

void RobotController::GetTcpForce(double force[6])
{
	for(int i=0;i<6;i++)
	{
		m_TcpForce[i]=asySocket->robotState.TCP_force[i];
	/*	m_TcpForce[i]=RobotMath::Round(m_TcpForce[i] ,1);*/
		/*m_TcpForce[i]=RobotMath::Round(m_TcpForce[i] ,0);*/
		m_TcpForce[i]-=m_TcpForceBais[i];
		force[i]=m_TcpForce[i];
	}
}

void RobotController::SetBias()
{
	for(int i=0;i<6;i++)
	{
		m_TcpForceBais[i]=asySocket->robotState.TCP_force[i];
	}
}

double RobotController::GetForce3D()
{
	double sum=0;
	for(int i=0;i<3;i++)
	{
		sum+=pow(m_TcpForce[i],2);
	}

	return sqrt(sum);
}

double RobotController::GetTorque3D()
{
	double sum=0;
	for(int i=3;i<6;i++)
	{
		sum+=pow(m_TcpForce[i],2);
	}

	return sqrt(sum);
}

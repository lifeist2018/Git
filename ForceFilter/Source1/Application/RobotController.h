#ifndef ROBOTCONTROLLER_H
#define ROBOTCONTROLLER_H
//
//#ifndef _WINSOCK2API_
//#define _WINSOCK2API_
//#define _WINSOCKAPI_ 
//#endif

#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif


#include <QObject>
#include <QMutex>
#include <QMutexLocker>

#include <AsySocketClient.h>


using namespace std;

const double ConstJointHome[6] = {0,-90,0,-90,0,0};
const double ConstJointFolder[6] = {-54.20,1.77,-161.82,-99.53,-178.74,-2.1};
class AngularPose;

class  RobotController : public QObject
{
	Q_OBJECT

public:
	static RobotController* instance()
	{
		static QMutex mutex;
		if (!m_instance)
		{
			QMutexLocker locker(&mutex);
			if (!m_instance)
			{
				m_instance = new RobotController();
			}
		}
		return m_instance;
	}
	enum PoseEnum
	{
		x,
		y,
		z,
		rx,
		ry,
		rz,
	};
	enum RobotState
	{
		none,
		poweroff,
		idle,
		run,
	};
	void Connect(QString,quint16);
	void Diconnect();
	void SetRobotVersion(AsySocketClient::RobotVersion);
	void SetJointSpeed(double);
	void SetJointAcceleration(double);
	void SetToolSpeed(double);
	void SetToolAcceleration(double);
	void PowerOn();
	void PowerOff();
	void ShutDown();
	void SetRobotmodeRun();
	void EmergencyStopRecover();
	void SecurityStopRecover();
	void SetRobotTeachMode();
	void SetRobotTeachModeEnd();
	bool Initialization();
	void JointAdjust(int, int);
	void CartesianAdjustBase(PoseEnum, int);
	void CartesianAdjustTcp(PoseEnum, int);
	void Stopj();
	void Stopl();
	void MoveTo(double*);
	void MoveJointTo(double*);
	void MoveToHome();
	void MoveToFolder();
	void SetSpeed(double);
	void GetKin(double*,double*);
	bool GetInverseKin(double* pose,double* joint,double* jointRefer);
	bool IfHaveInverseKin(double* pose);
	void MoveRobotToPlanPose(double* pose);
	void MoveRobotToPlanPose(double* pose,double* jointRefer);
	void MoveRobotToTrajectory(double* pose);
	void MoveRobotTcpToTrajectory(double* pose);

	void SetTcp(double* pose);
	void FootFix();
	void FootUp();
	void EnableFootSwitch();
	void DisableFootSwitch();
	void GetCurrentPose(double*);
	void GetCurrentJoint(double*);
	void Speedl(double* xd,double a,double min);
	void Speedj(double* qd,double a,double min);
	void Servoc(double* pose,double a,double v,double rsdius=0);
	void Servoj(double* q,double t=0.008, double lookaheadt=0.1, double gain=300);
	void Movep(double* pose);
	void MoveWaypoint(double* pose);
	void MoveWaypoint(double* pose,double* home);
	bool ChooseJointSolution(double*,double*,double*);
	void GetCurrentJointSpeed(double*);
	double GetRobotSecurityState();
	void SetBias();
	void GetTcpForce(double force[6]);//tcp force
	double GetForce3D();
	double GetTorque3D();

private:
	void SetUnlockProtectiveStop();
	void SetFreedrive();
	void StartTeachMode();
	void EndTeachMode();
	QMatrix4x4 GetMatrixFromRotateVector(QVector3D,QVector3D);
	bool NearToPose(double *targetPose);
	bool NearToJoint(double *targetJoint);
    
public slots:
	void socketConnected();
	void socketDisconnected();
	void socketReceiveData(const AsySocketClient::RobotState &);
	void slotExceedPositionLimit(bool);
	void slotExceedSpeedLimit(bool);
	void slotNearToPositionLimit(bool);
	void slotConnect();
	void socketDataBlocking();
signals:
	void OnConnect();
	void OnDisconnect();
	void OnReceiveData(const AsySocketClient::RobotState &);
	void OnNearToTarget();
	void OnRobotPowerOff();
	void OnRobotIdle();
	void OnRobotRun();
	void OnRobotExceedPositionLimit(bool);
	void OnRobotNearToPositionLimit(bool);
	void OnOnRobotExceedSpeedLimit(bool);
	void OnDataBlocking();
private:
	RobotController(QObject *parent=0);
	~RobotController();
	QString m_ipAddress;
	AsySocketClient *asySocket;
	double m_jointSpeed;
	double m_jointAcceleration;
	double m_toolSpeed;
	double m_toolAcceleration;
	static RobotController* m_instance;
	double targetPose[6];
	double targetJoint[6];
	bool m_targetPoseEnable;
	bool m_targetJointEnable;
	double m_jointPositionLimitMax;
	double m_jointPositionLimitMin;
	double m_jointNearToPositionLimitMax;
	double m_jointNearToPositionLimitMin;
	double m_jointSpeedLimitMax;
	double m_jointSpeedLimitMin;
	QString m_callNearToLimitStatus;
	QString m_callPositionLimitStatus;
	QString m_callSpeedLimitStatus;
	int m_D0;
	int m_D1;
	int m_D2;
	RobotState m_previousrobotState;
	double m_TcpForce[6];
	double m_TcpForceBais[6];
};

#endif // ROBOTCONTROLLER_H
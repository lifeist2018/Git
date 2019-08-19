#ifndef ASYSOCKETCLIENT_H
#define ASYSOCKETCLIENT_H


#include <QTcpSocket>
#include <QMetaType>
#include <QVariant>
#include <QMutex>

#define PI 3.1415926 

class AsySocketClient : public QObject
{
	Q_OBJECT

public:
	 AsySocketClient(QObject *parent=0);
	~AsySocketClient();
	enum RobotVersion
	{
		V18,
		V30,
		V32,
		V35,
	};
	 RobotVersion robotVersion;
	struct RobotState
	{
		double SpeedFraction;
		double JointPosition[6];
		double TargetJointPosition[6];
		double JointSpeed[6];
		double ToolPosition[3];
		double ToolOrientation[3];
		bool DigitalOut[8];
		bool DigitalIn[8];
		bool IsRobotConnected;
		bool IsRealRobotEnabled;
		bool IsPowerOnRobot;
		bool IsEmergencyStopped;
		bool IsSecurityStopped;
		bool IsProgramRunning;
		bool IsProgramPaused;
		/*	 bool ToolIn[2];
		bool ToolOut[2];*/
		bool TO0;
		bool TO1;
		bool TI0;
		bool TI1;
		unsigned int RobotMode;
		unsigned int Message_Size;
		double InnerForce[6];//force mode data

		/// <summary>
		/// 控制器通电时间
		/// </summary>
		double Time;
		/// <summary>
		/// 关节目标位置
		/// </summary>
		double q_target[6];//单位：rad
		/// <summary>
		/// 关节目标速度
		/// </summary>
		double qd_target[6];//单位：rad/s
		/// <summary>
		/// 关节目标加速度
		/// </summary>
		double qdd_target[6];//单位：rad/s^2
		/// <summary>
		/// 关节目标电流
		/// </summary>
		double I_target[6];//单位：A
		/// <summary>
		/// 关节目标扭矩
		/// </summary>
		double M_target[6];//单位：
		/// <summary>
		/// 关节实际位置
		/// </summary>
		double q_actual[6];//单位：rad
		/// <summary>
		/// 关节实际速度
		/// </summary>
		double qd_actual[6];//单位：rad/s
		/// <summary>
		/// 关节实际电流
		/// </summary>
		double I_actual[6];//单位：A
		/// <summary>
		/// 关节实际控制
		/// </summary>
		double I_control[6];//单位：A
		/// <summary>
		/// TCP位置
		/// </summary>
		double Tool_vector_actual[6];//单位：
		/// <summary>
		/// TCP速度
		/// </summary>
		double TCP_speed_actual[6];//单位：
		/// <summary>
		/// TCP力
		/// </summary>
		double TCP_force[6];//单位：
		/// <summary>
		/// TCP目标位置
		/// </summary>
		double Tool_vector_target[6];//单位：
		/// <summary>
		/// TCP目标速度
		/// </summary>
		double TCP_speed_target[6];//单位：(m,m,m,rad,rad,rad)
		/// <summary>
		/// 输入位状态
		/// </summary>
		double Digital_input_bits;
		/// <summary>
		/// 输出位状态
		/// </summary>
		double Digital_output_bits;
		/// <summary>
		/// 电机温度
		/// </summary>
		double Motor_temperatures[6];//单位：°C
		/// <summary>
		/// 程序扫描时间
		/// </summary>
		double Controller_Timer;
		/// <summary>
		/// 测试保留
		/// </summary>
		double Test_value;
		/// <summary>
		/// 机器人模式
		/// </summary>
		double Robot_mode;
		/// <summary>
		/// 机器人模式
		/// </summary>
		unsigned short Robot_mode_Int;
		/// <summary>
		/// 机器人模式
		/// </summary>
		QString Robot_mode_String;
		/// <summary>
		/// 关节模式
		/// </summary>
		double Joint_Modes[6];
		/// <summary>
		/// 关节模式
		/// </summary>
		unsigned short Joint_Modes_Int[16];
		/// <summary>
		/// 关节模式
		/// </summary>
		QString Joint_Modes_String[6];
		/// <summary>
		/// 安全模式
		/// </summary>
		double Safty_Mode;
		/// <summary>
		/// 安全模式
		/// </summary>
		unsigned short Safty_mode_Int;
		/// <summary>
		/// 安全模式
		/// </summary>
		QString Safty_mode_String;
		/// <summary>
		/// 保留
		/// </summary>
		double UR_Only1[6];
		/// <summary>
		/// 工具加速度
		/// </summary>
		double Tool_Accelerometer_values[3];
		/// <summary>
		/// 保留
		/// </summary>
		double UR_Only2[6];
		/// <summary>
		/// 速度比例
		/// </summary>
		double Speed_scaling;
		/// <summary>
		/// 动量值
		/// </summary>
		double Linear_momentum_norm;
		/// <summary>
		/// 保留
		/// </summary>
		double UR_Only3;
		/// <summary>
		/// 保留
		/// </summary>
		double UR_Only4;
		/// <summary>
		/// 控制板电压
		/// </summary>
		double V_main;//单位：V
		/// <summary>
		/// 机器人电压
		/// </summary>
		double V_robot;//单位：V
		/// <summary>
		/// 机器人电流
		/// </summary>
		double I_robot;//单位：A
		/// <summary>
		/// 关节电压
		/// </summary>
		double V_actual[6];
		/// <summary>
		/// 程序状态
		/// </summary>
		double Program_state;
	}robotState;
	 QString GetCurrentDateTime();
	 void TimeOutConnect(QString,quint16);
	 void Disconnect();
	 void SetRobotVersion(RobotVersion);
	 void SendStream(QString);
private:
	void AnalyzeReceivePacket30002();
	void AnalyzeReceivePacket30003();
	void DataStreamReader30002_V18(unsigned int,unsigned int);
	void DataStreamReader30002_V30_V32(unsigned int,unsigned int);
	void DataStreamReader30003_V18(unsigned int,unsigned int);
	void DataStreamReader30003_V30(unsigned int,unsigned int);
	void DataStreamReader30003_V32(unsigned int,unsigned int);
	void DataStreamReader30003_V35(unsigned int,unsigned int);
	double ReadDouble(unsigned int);
	double ReadDouble(QByteArray, unsigned int);
	unsigned int ReadInt(unsigned int);
	unsigned int ReadInt(QByteArray,unsigned int);
	bool ReadBool(unsigned int);
	bool ReadBool(QByteArray,unsigned int);
	double ConvertToAngle(double);
	double MathRound(double);
	QMutex mutex;
public slots:
	void socketConnected();
	void socketDisconnected();
	void socketStateChanged(QAbstractSocket::SocketState);
	void socketError(QAbstractSocket::SocketError);
	void socketReadyRead();
signals:
	void OnConnect();
	void OnDisconnect();
	void OnReceiveData(const AsySocketClient::RobotState &);
private:
	QTcpSocket *socket;
	bool isSocketConnect;
	int bufferIndex;
	QByteArray splitDataBuffer;
	quint16 connectPort;
	//包长度
    static const int dataLengthV18 = 812;
    static const int dataLengthV30 = 1044;
    static const int dataLengthV32 = 1060;
	//static const int dataLengthV35 = 1108;
	static const int dataLengthV35 = 1116;
	//QMutex mutex;
public:
};

#endif // ASYSOCKETCLIENT_H
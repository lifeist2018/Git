#include "AsySocketClient.h"
#include <QDebug>
#include <QDateTime>
#include <cmath>
#include <iostream>
#include <vector>

using namespace std;

AsySocketClient::AsySocketClient(QObject *parent) : QObject(parent)
{
	robotVersion = RobotVersion::V18; //初始值
	bufferIndex = 0;
	isSocketConnect = false;
	socket = new QTcpSocket(this);
	connect(socket, SIGNAL(connected()),SLOT(socketConnected())); 
	connect(socket, SIGNAL(disconnected()),SLOT(socketDisconnected())); 
	connect(socket, SIGNAL(stateChanged(QAbstractSocket::SocketState)),SLOT(socketStateChanged(QAbstractSocket::SocketState))); 
	connect(socket, SIGNAL(readyRead()),SLOT(socketReadyRead()) );  
	connect(socket, SIGNAL(error(QAbstractSocket::SocketError)),SLOT(socketError(QAbstractSocket::SocketError)));
	for(int i=0;i<6;i++)
	{
		robotState.JointPosition[i] = 0;
		robotState.JointSpeed[i] = 0;
	}
}

AsySocketClient::~AsySocketClient()
{

}

void AsySocketClient::SetRobotVersion(RobotVersion myVersion)
{
	robotVersion = myVersion;
}

void AsySocketClient::TimeOutConnect(QString ipAddress,quint16 port)
{
	if(!isSocketConnect)
	{
		bufferIndex = 0;
		connectPort = port;
		socket->connectToHost(ipAddress,port);
		if(!socket->waitForConnected(1000))
		{
			socket->disconnectFromHost();
			emit OnDisconnect();
			isSocketConnect = false;
			return;
		}
	}
}

void AsySocketClient::Disconnect()
{
	socket->disconnectFromHost();
	isSocketConnect = false;
}

void AsySocketClient::socketConnected()
{
	///////////////////////////////////////////
	QString current_date = GetCurrentDateTime();
	qDebug("socketConnected %s ", qPrintable(current_date));
	///////////////////////////////////////////
	emit OnConnect();
	isSocketConnect = true;
}

void AsySocketClient::socketDisconnected()
{
	///////////////////////////////////////////
	//QString current_date = GetCurrentDateTime();
	//qDebug("socketDisconnected %s ", qPrintable(current_date));
	///////////////////////////////////////////
	emit OnDisconnect();
	isSocketConnect = false;
}

void AsySocketClient::socketStateChanged(QAbstractSocket::SocketState socketState)
{
	///////////////////////////////////////////
	//QString current_date = GetCurrentDateTime();
	//qDebug("socketStateChanged %s ", qPrintable(current_date));
	//qDebug("socketState: %d",socketState);
	///////////////////////////////////////////
}

void AsySocketClient::socketError(QAbstractSocket::SocketError socketError)
{
	///////////////////////////////////////////
	//QString current_date = GetCurrentDateTime();
	//qDebug("socketError %s ", qPrintable(current_date));
	//qDebug("socketError: %d",socketError);
	///////////////////////////////////////////
}

void AsySocketClient::socketReadyRead()
{
		//qDebug("socketReadyRead <<start");
		////mutex.lock();
		//qDebug("splitDataBuffer length: %d",splitDataBuffer.length());
		QByteArray readDataBuffer = socket->readAll();
		//vector<unsigned char> myVector(readDataBuffer.begin(),readDataBuffer.end());
		splitDataBuffer.append(readDataBuffer);
		//qDebug("readDataBuffer length: %d",readDataBuffer.length());
		//if(robotVersion == RobotVersion::V18)
		//{
		//	DataStreamReader30002_V18();
		//}
		//else
		//{
		//	DataStreamReader30002_V30_V32();
		//}
		if(connectPort == 30002)
		{
			AnalyzeReceivePacket30002();
		}
		else if(connectPort == 30003)
		{
			AnalyzeReceivePacket30003();
		}
		//mutex.unlock();
		//qDebug("socketReadyRead end>>");
}

void AsySocketClient::AnalyzeReceivePacket30002()
{
	unsigned int streamOffset = 0;

	while (streamOffset <= (splitDataBuffer.length() - 4))
	{
		//获得数据包长度
		unsigned int pacLength;
		pacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
		pacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
		pacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
		pacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 

		//////////////////////////////////////
		//qDebug("pacLength: %d",pacLength);
		//////////////////////////////////////

		if(pacLength < 100)
		{
			//数据包长度小于100的丢弃
			streamOffset = streamOffset + pacLength;
			continue;
		}
		else
		{
			if (pacLength <= (splitDataBuffer.length() - streamOffset))
			{
				//数据包长度小于缓冲区长度则开始拆包

				if(robotVersion == RobotVersion::V18)
				{
					DataStreamReader30002_V18(streamOffset,pacLength);
				}
				else if(robotVersion == RobotVersion::V30)
				{
					DataStreamReader30002_V30_V32(streamOffset,pacLength);
				}
				else if(robotVersion == RobotVersion::V32||robotVersion == RobotVersion::V35)
				{
					DataStreamReader30002_V30_V32(streamOffset,pacLength);
				}
				streamOffset = streamOffset + pacLength;
			}
			else
			{
				//数据包长度大于缓冲区剩余长度则保留数据
				break;
			}
		}
	}
	if(streamOffset == splitDataBuffer.length())
	{
		splitDataBuffer.clear();
	}
	else
	{
		splitDataBuffer.remove(0,streamOffset);
	}
}

void AsySocketClient::AnalyzeReceivePacket30003()
{
	//QString msg = QString("%1 -> %2 threadid:[%3]")
	//           .arg(__FILE__)
	//           .arg(__FUNCTION__)
	//           .arg((int)QThread::currentThreadId());
	// 
	//   qDebug() << msg;

	unsigned int streamOffset = 0;

	if(robotVersion == RobotVersion::V18)
	{
		while (streamOffset <= (splitDataBuffer.length() - 4))
		{
			//获得数据包长度
			unsigned int pacLength;
			pacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
			pacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
			pacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
			pacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 
			robotState.Message_Size = pacLength;

			if (pacLength <= (splitDataBuffer.length() - streamOffset))
			{
				//数据包长度小于缓冲区长度则开始拆包
				if (robotState.Message_Size == dataLengthV18)
				{
					DataStreamReader30003_V18(streamOffset,pacLength);
				}

				streamOffset = streamOffset + pacLength;

			}
			else
			{
				//数据包长度大于缓冲区剩余长度则保留数据
				break;
			}
		}
		if(streamOffset == splitDataBuffer.length())
		{
			splitDataBuffer.clear();
		}
		else
		{
			splitDataBuffer.remove(0,streamOffset);
		}
	}
	else if(robotVersion == RobotVersion::V30)
	{
		while (streamOffset <= (splitDataBuffer.length() - 4))
		{
			//获得数据包长度
			unsigned int pacLength;
			pacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
			pacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
			pacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
			pacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 
			robotState.Message_Size = pacLength;

			if (pacLength <= (splitDataBuffer.length() - streamOffset))
			{
				//数据包长度小于缓冲区长度则开始拆包
				if (robotState.Message_Size == dataLengthV30)
				{
					DataStreamReader30003_V30(streamOffset,pacLength);
				}

				streamOffset = streamOffset + pacLength;

			}
			else
			{
				//数据包长度大于缓冲区剩余长度则保留数据
				break;
			}
		}
		if(streamOffset == splitDataBuffer.length())
		{
			splitDataBuffer.clear();
		}
		else
		{
			splitDataBuffer.remove(0,streamOffset);
		}
	}
	else if(robotVersion == RobotVersion::V32)
	{
		while (streamOffset <= (splitDataBuffer.length() - 4))
		{
			//获得数据包长度
			unsigned int pacLength;
			pacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
			pacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
			pacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
			pacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 
			robotState.Message_Size = pacLength;

			if (pacLength <= (splitDataBuffer.length() - streamOffset))
			{
				//数据包长度小于缓冲区长度则开始拆包
				if (robotState.Message_Size == dataLengthV32)
				{
					DataStreamReader30003_V32(streamOffset,pacLength);
				}

				streamOffset = streamOffset + pacLength;

			}
			else
			{
				//数据包长度大于缓冲区剩余长度则保留数据
				break;
			}
		}
		if(streamOffset == splitDataBuffer.length())
		{
			splitDataBuffer.clear();
		}
		else
		{
			splitDataBuffer.remove(0,streamOffset);
		}
	}
	else if(robotVersion == RobotVersion::V35)
	{
		while (streamOffset <= (splitDataBuffer.length() - 4))
		{
			//获得数据包长度
			unsigned int pacLength;
			pacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
			pacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
			pacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
			pacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 
			robotState.Message_Size = pacLength;

			if (pacLength <= (splitDataBuffer.length() - streamOffset))
			{
				//数据包长度小于缓冲区长度则开始拆包
				if (robotState.Message_Size == dataLengthV35)
				{
					DataStreamReader30003_V35(streamOffset,dataLengthV32);
				}

				streamOffset = streamOffset + pacLength;

			}
			else
			{
				//数据包长度大于缓冲区剩余长度则保留数据
				break;
			}
		}
		if(streamOffset == splitDataBuffer.length())
		{
			splitDataBuffer.clear();
		}
		else
		{
			splitDataBuffer.remove(0,streamOffset);
		}
	}
}

//void AsySocketClient::DataStreamReader30002_V18()
//{
//	//已经获得了读取到数据的长度，现在要解析这些数据
//	unsigned int pacLengthSum = 0;
//	unsigned int streamOffset = 0;
//	unsigned int subPacLength = 0;
//	unsigned int subPacType = 0;
//
//	while (streamOffset <= (splitDataBuffer.length() - 4))
//	{
//		//获得数据包长度
//		unsigned int pacLength;
//		pacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
//		pacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
//		pacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
//		pacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 
//		streamOffset = streamOffset+4;
//		//////////////////////////////////////
//		//qDebug("pacLength: %d",pacLength);
//		//////////////////////////////////////
//
//		if(pacLength < 100)
//		{
//			//数据包长度小于100的丢弃
//			streamOffset = streamOffset + pacLength - 4;
//			pacLengthSum += pacLength;
//			continue;
//		}
//
//		if (pacLength <= (splitDataBuffer.length() - pacLengthSum))
//		{
//			//数据包长度小于缓冲区长度则开始拆包
//			streamOffset = streamOffset + 1; //包长度下有一个字节的包描述
//			pacLengthSum = pacLengthSum + pacLength;
//			while (streamOffset<pacLengthSum)
//			{
//				subPacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
//				subPacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
//				subPacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
//				subPacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 
//				streamOffset = streamOffset + 4;
//				subPacType = splitDataBuffer[streamOffset] & 0x000000FF;
//				streamOffset = streamOffset + 1;
//				//////////////////////////////////////
//				//qDebug("subPacType: %d",subPacType);
//				//qDebug("subPacLength: %d",subPacLength);
//				//////////////////////////////////////
//				switch (subPacType)
//				{
//				case 0:
//					//解析Robot Mode Data包
//					robotState.IsRobotConnected = (bool)splitDataBuffer[streamOffset+8];
//					robotState.IsRealRobotEnabled = (bool)splitDataBuffer[streamOffset+9];
//					robotState.IsPowerOnRobot = (bool)splitDataBuffer[streamOffset+10];
//					robotState.IsEmergencyStopped = (bool)splitDataBuffer[streamOffset+11];
//					robotState.IsSecurityStopped = (bool)splitDataBuffer[streamOffset+12];
//					robotState.IsProgramRunning = (bool)splitDataBuffer[streamOffset+13];
//					robotState.IsProgramPaused = (bool)splitDataBuffer[streamOffset+14];
//					robotState.RobotMode = (unsigned int)splitDataBuffer[streamOffset+15];
//					robotState.SpeedFraction = ReadDouble(streamOffset+16);
//					break;
//				case 1:
//					//解析Joint Data包
//					for(int i=0;i<6;i++)
//					{
//						unsigned int subOffset = streamOffset + i*41;
//						robotState.JointPosition[i] = ReadDouble(subOffset);
//						robotState.JointPosition[i] = robotState.JointPosition[i]*180/PI;
//						//////////保留2位小数///////
//						if(robotState.JointPosition[i]>=0)
//						{
//							robotState.JointPosition[i] += 0.005;
//						}
//						else
//						{
//							robotState.JointPosition[i] -= 0.005;
//						}
//						int temp = (int)(robotState.JointPosition[i]*100);
//						robotState.JointPosition[i] = temp / 100.0;
//						///////////////////////////
//						robotState.TargetJointPosition[i] = ReadDouble(subOffset+8);
//						robotState.TargetJointPosition[i] = robotState.TargetJointPosition[i]*180/PI;
//						//////////保留2位小数///////
//						if(robotState.TargetJointPosition[i]>=0)
//						{
//							robotState.TargetJointPosition[i] += 0.005;
//						}
//						else
//						{
//							robotState.TargetJointPosition[i] -= 0.005;
//						}
//						temp = (int)(robotState.TargetJointPosition[i]*100);
//						robotState.TargetJointPosition[i] = temp / 100.0;
//						///////////////////////////
//						robotState.JointSpeed[i] = ReadDouble(subOffset+16);
//						robotState.JointSpeed[i] = robotState.JointSpeed[i]*180/PI;
//					}
//					break;
//				case 4:
//					//解析Cartesian Info包
//					robotState.ToolPosition[0] = ReadDouble(streamOffset);
//					robotState.ToolPosition[1] = ReadDouble(streamOffset + 8);
//					robotState.ToolPosition[2] = ReadDouble(streamOffset + 8*2);
//					robotState.ToolOrientation[0] = ReadDouble(streamOffset + 8*3);
//					robotState.ToolOrientation[1] = ReadDouble(streamOffset + 8*4);
//					robotState.ToolOrientation[2] = ReadDouble(streamOffset + 8*5);
//					break;
//				case 3:
//					//解析Masterboard Data数据包
//					unsigned int digialOut = splitDataBuffer[streamOffset+3];
//					robotState.DigitalOut[0] = (bool)((digialOut & 0x01) >> 0);
//					robotState.DigitalOut[1] = (bool)((digialOut & 0x02) >> 1);
//					robotState.DigitalOut[2] = (bool)((digialOut & 0x04) >> 2);
//					robotState.DigitalOut[3] = (bool)((digialOut & 0x08) >> 3);
//					robotState.DigitalOut[4] = (bool)((digialOut & 0x10) >> 4);
//					robotState.DigitalOut[5] = (bool)((digialOut & 0x20) >> 5);
//					robotState.DigitalOut[6] = (bool)((digialOut & 0x40) >> 6);
//					robotState.DigitalOut[7] = (bool)((digialOut & 0x80) >> 7);
//					break;
//				}
//				streamOffset = streamOffset + subPacLength - 5;
//			}
//			emit OnReceiveData(robotState);
//		}
//		else
//		{
//			//数据包长度大于缓冲区剩余长度则保留数据
//			break;
//		}
//	}
//	if(streamOffset == splitDataBuffer.length())
//	{
//		splitDataBuffer.clear();
//	}
//	else
//	{
//		splitDataBuffer.remove(0,streamOffset-4);
//	}
//}
//
//void AsySocketClient::DataStreamReader30002_V30_V32()
//{
//	//已经获得了读取到数据的长度，现在要解析这些数据
//	unsigned int pacLengthSum = 0;
//	unsigned int streamOffset = 0;
//	unsigned int subPacLength = 0;
//	unsigned int subPacType = 0;
//
//	while (streamOffset <= (splitDataBuffer.length() - 4))
//	{
//		//获得数据包长度
//		unsigned int pacLength;
//		pacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
//		pacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
//		pacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
//		pacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 
//		streamOffset = streamOffset+4;
//		//////////////////////////////////////
//		//qDebug("pacLength: %d",pacLength);
//		//////////////////////////////////////
//
//		if(pacLength < 100)
//		{
//			//数据包长度小于100的丢弃
//			streamOffset = streamOffset + pacLength - 4;
//			pacLengthSum += pacLength;
//			continue;
//		}
//
//		if (pacLength <= (splitDataBuffer.length() - pacLengthSum))
//		{
//			//数据包长度小于缓冲区长度则开始拆包
//			streamOffset = streamOffset + 1; //包长度下有一个字节的包描述
//			pacLengthSum = pacLengthSum + pacLength;
//			while (streamOffset<pacLengthSum)
//			{
//				subPacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
//				subPacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
//				subPacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
//				subPacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 
//				streamOffset = streamOffset + 4;
//				subPacType = splitDataBuffer[streamOffset] & 0x000000FF;
//				streamOffset = streamOffset + 1;
//				//////////////////////////////////////
//				//qDebug("subPacType: %d",subPacType);
//				//qDebug("subPacLength: %d",subPacLength);
//				//////////////////////////////////////
//				switch (subPacType)
//				{
//					case 0:
//						//解析Robot Mode Data包
//						robotState.IsRobotConnected = (bool)splitDataBuffer[streamOffset+8];
//						robotState.IsRealRobotEnabled = (bool)splitDataBuffer[streamOffset+9];
//						robotState.IsPowerOnRobot = (bool)splitDataBuffer[streamOffset+10];
//						robotState.IsEmergencyStopped = (bool)splitDataBuffer[streamOffset+11];
//						robotState.IsSecurityStopped = (bool)splitDataBuffer[streamOffset+12];
//						robotState.IsProgramRunning = (bool)splitDataBuffer[streamOffset+13];
//						robotState.IsProgramPaused = (bool)splitDataBuffer[streamOffset+14];
//						robotState.RobotMode = (unsigned int)splitDataBuffer[streamOffset+15];
//						robotState.SpeedFraction = ReadDouble(streamOffset+17);
//						break;
//					case 1:
//						//解析Joint Data包
//						for(int i=0;i<6;i++)
//						{
//							unsigned int subOffset = streamOffset + i*41;
//							robotState.JointPosition[i] = ReadDouble(subOffset);
//							robotState.JointPosition[i] = robotState.JointPosition[i]*180/PI;
//							//////////保留2位小数///////
//							if(robotState.JointPosition[i]>=0)
//							{
//								robotState.JointPosition[i] += 0.005;
//							}
//							else
//							{
//								robotState.JointPosition[i] -= 0.005;
//							}
//							int temp = (int)(robotState.JointPosition[i]*100);
//							robotState.JointPosition[i] = temp / 100.0;
//							///////////////////////////
//							robotState.TargetJointPosition[i] = ReadDouble(subOffset+8);
//							robotState.TargetJointPosition[i] = robotState.TargetJointPosition[i]*180/PI;
//							//////////保留2位小数///////
//							if(robotState.TargetJointPosition[i]>=0)
//							{
//								robotState.TargetJointPosition[i] += 0.005;
//							}
//							else
//							{
//								robotState.TargetJointPosition[i] -= 0.005;
//							}
//							temp = (int)(robotState.TargetJointPosition[i]*100);
//							robotState.TargetJointPosition[i] = temp / 100.0;
//							///////////////////////////
//							robotState.JointSpeed[i] = ReadDouble(subOffset+16);
//							robotState.JointSpeed[i] = robotState.JointSpeed[i]*180/PI;
//						}
//						break;
//					case 4:
//						//解析Cartesian Info包
//						robotState.ToolPosition[0] = ReadDouble(streamOffset);
//						robotState.ToolPosition[1] = ReadDouble(streamOffset + 8);
//						robotState.ToolPosition[2] = ReadDouble(streamOffset + 8*2);
//						robotState.ToolOrientation[0] = ReadDouble(streamOffset + 8*3);
//						robotState.ToolOrientation[1] = ReadDouble(streamOffset + 8*4);
//						robotState.ToolOrientation[2] = ReadDouble(streamOffset + 8*5);
//						break;
//					case 3:
//						//解析Masterboard Data数据包
//						unsigned int digialOut = splitDataBuffer[streamOffset+7];
//						robotState.DigitalOut[0] = (bool)((digialOut & 0x01) >> 0);
//						robotState.DigitalOut[1] = (bool)((digialOut & 0x02) >> 1);
//						robotState.DigitalOut[2] = (bool)((digialOut & 0x04) >> 2);
//						robotState.DigitalOut[3] = (bool)((digialOut & 0x08) >> 3);
//						robotState.DigitalOut[4] = (bool)((digialOut & 0x10) >> 4);
//						robotState.DigitalOut[5] = (bool)((digialOut & 0x20) >> 5);
//						robotState.DigitalOut[6] = (bool)((digialOut & 0x40) >> 6);
//						robotState.DigitalOut[7] = (bool)((digialOut & 0x80) >> 7);
//						break;
//				}
//				streamOffset = streamOffset + subPacLength - 5;
//			}
//			emit OnReceiveData(robotState);
//		}
//		else
//		{
//			//数据包长度大于缓冲区剩余长度则保留数据
//			break;
//		}
//	}
//	if(streamOffset == splitDataBuffer.length())
//	{
//		splitDataBuffer.clear();
//	}
//	else
//	{
//		splitDataBuffer.remove(0,streamOffset-4);
//	}
//}

void AsySocketClient::DataStreamReader30002_V18(unsigned int streamOffset,unsigned int pacLength)
{
	unsigned int subPacLength = 0;
	unsigned int subPacType = 0;
	unsigned int pacLengthSum = streamOffset + pacLength;
	unsigned int headerLength = 5;

	streamOffset = streamOffset + headerLength; 
	while (streamOffset<pacLengthSum)
	{
		//subPacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
		//subPacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
		//subPacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
		//subPacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 

		subPacLength = ReadInt(streamOffset);

		streamOffset = streamOffset + 4;
		subPacType = splitDataBuffer[streamOffset] & 0x000000FF;
		streamOffset = streamOffset + 1;
		//////////////////////////////////////
		//qDebug("subPacType: %d",subPacType);
		//qDebug("subPacLength: %d",subPacLength);
		//////////////////////////////////////
		switch (subPacType)
		{
		case 0:
			//解析Robot Mode Data包
			robotState.IsRobotConnected = (bool)splitDataBuffer[streamOffset+8];
			robotState.IsRealRobotEnabled = (bool)splitDataBuffer[streamOffset+9];
			robotState.IsPowerOnRobot = (bool)splitDataBuffer[streamOffset+10];
			robotState.IsEmergencyStopped = (bool)splitDataBuffer[streamOffset+11];
			robotState.IsSecurityStopped = (bool)splitDataBuffer[streamOffset+12];
			robotState.IsProgramRunning = (bool)splitDataBuffer[streamOffset+13];
			robotState.IsProgramPaused = (bool)splitDataBuffer[streamOffset+14];
			robotState.RobotMode = (unsigned int)splitDataBuffer[streamOffset+15];
			robotState.SpeedFraction = ReadDouble(streamOffset+16);
			break;
		case 1:
			//解析Joint Data包
			for(int i=0;i<6;i++)
			{
				unsigned int subOffset = streamOffset + i*41;
				robotState.JointPosition[i] = ReadDouble(subOffset);
				robotState.JointPosition[i] = robotState.JointPosition[i]*180/PI;
				//////////保留2位小数///////
				if(robotState.JointPosition[i]>=0)
				{
					robotState.JointPosition[i] += 0.005;
				}
				else
				{
					robotState.JointPosition[i] -= 0.005;
				}
				int temp = (int)(robotState.JointPosition[i]*100);
				robotState.JointPosition[i] = temp / 100.0;
				///////////////////////////
				robotState.TargetJointPosition[i] = ReadDouble(subOffset+8);
				robotState.TargetJointPosition[i] = robotState.TargetJointPosition[i]*180/PI;
				//////////保留2位小数///////
				if(robotState.TargetJointPosition[i]>=0)
				{
					robotState.TargetJointPosition[i] += 0.005;
				}
				else
				{
					robotState.TargetJointPosition[i] -= 0.005;
				}
				temp = (int)(robotState.TargetJointPosition[i]*100);
				robotState.TargetJointPosition[i] = temp / 100.0;
				///////////////////////////
				robotState.JointSpeed[i] = ReadDouble(subOffset+16);
				robotState.JointSpeed[i] = robotState.JointSpeed[i]*180/PI;
			}
			break;
		case 4:
			//解析Cartesian Info包
			robotState.ToolPosition[0] = ReadDouble(streamOffset);
			robotState.ToolPosition[1] = ReadDouble(streamOffset + 8);
			robotState.ToolPosition[2] = ReadDouble(streamOffset + 8*2);
			robotState.ToolOrientation[0] = ReadDouble(streamOffset + 8*3);
			robotState.ToolOrientation[1] = ReadDouble(streamOffset + 8*4);
			robotState.ToolOrientation[2] = ReadDouble(streamOffset + 8*5);
			break;
		case 3:
			//解析Masterboard Data数据包
			int digialOut = splitDataBuffer[streamOffset+3];
			int byteToolOutput = splitDataBuffer[streamOffset + 2];
            int byteDigitalInput = splitDataBuffer[streamOffset + 1];
            int byteToolInput = splitDataBuffer[streamOffset + 0];

			robotState.DigitalOut[0] = (bool)((digialOut & 0x01) >> 0);
			robotState.DigitalOut[1] = (bool)((digialOut & 0x02) >> 1);
			robotState.DigitalOut[2] = (bool)((digialOut & 0x04) >> 2);
			robotState.DigitalOut[3] = (bool)((digialOut & 0x08) >> 3);
			robotState.DigitalOut[4] = (bool)((digialOut & 0x10) >> 4);
			robotState.DigitalOut[5] = (bool)((digialOut & 0x20) >> 5);
			robotState.DigitalOut[6] = (bool)((digialOut & 0x40) >> 6);
			robotState.DigitalOut[7] = (bool)((digialOut & 0x80) >> 7);

			robotState.TO0 = (bool)(((byteToolOutput & 0x01) >> 0));
            robotState.TO1 = (bool)(((byteToolOutput & 0x02) >> 1));
            robotState.TI0 = (bool)(((byteToolInput & 0x01) >> 0));
            robotState.TI1 = (bool)(((byteToolInput & 0x02) >> 1));
			break;
		}
		streamOffset = streamOffset + subPacLength - 5;
	}
	emit OnReceiveData(robotState);
}

void AsySocketClient::DataStreamReader30002_V30_V32(unsigned int streamOffset,unsigned int pacLength)
{
	unsigned int subPacLength = 0;
	unsigned int subPacType = 0;
	unsigned int pacLengthSum = streamOffset + pacLength;
	unsigned int headerLength = 5;

	streamOffset = streamOffset + headerLength; 
	while (streamOffset<pacLengthSum)
	{
		//subPacLength = splitDataBuffer[streamOffset+3] & 0x000000FF;
		//subPacLength |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
		//subPacLength |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
		//subPacLength |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 

		subPacLength = ReadInt(streamOffset);

		streamOffset = streamOffset + 4;
		subPacType = splitDataBuffer[streamOffset] & 0x000000FF;
		streamOffset = streamOffset + 1;
		//////////////////////////////////////
		//qDebug("subPacType: %d",subPacType);
		//qDebug("subPacLength: %d",subPacLength);
		//////////////////////////////////////
		switch (subPacType)
		{
			case 0:
				//解析Robot Mode Data包
				robotState.IsRobotConnected = (bool)splitDataBuffer[streamOffset+8];
				robotState.IsRealRobotEnabled = (bool)splitDataBuffer[streamOffset+9];
				robotState.IsPowerOnRobot = (bool)splitDataBuffer[streamOffset+10];
				robotState.IsEmergencyStopped = (bool)splitDataBuffer[streamOffset+11];
				robotState.IsSecurityStopped = (bool)splitDataBuffer[streamOffset+12];
				robotState.IsProgramRunning = (bool)splitDataBuffer[streamOffset+13];
				robotState.IsProgramPaused = (bool)splitDataBuffer[streamOffset+14];
				robotState.RobotMode = (unsigned int)splitDataBuffer[streamOffset+15];
				robotState.SpeedFraction = ReadDouble(streamOffset+17);
				break;
			case 1:
				//解析Joint Data包
				for(int i=0;i<6;i++)
				{
					unsigned int subOffset = streamOffset + i*41;
					robotState.JointPosition[i] = ReadDouble(subOffset);
					robotState.JointPosition[i] = robotState.JointPosition[i]*180/PI;
					//////////保留2位小数///////
					if(robotState.JointPosition[i]>=0)
					{
						robotState.JointPosition[i] += 0.005;
					}
					else
					{
						robotState.JointPosition[i] -= 0.005;
					}
					int temp = (int)(robotState.JointPosition[i]*100);
					robotState.JointPosition[i] = temp / 100.0;
					///////////////////////////
					robotState.TargetJointPosition[i] = ReadDouble(subOffset+8);
					robotState.TargetJointPosition[i] = robotState.TargetJointPosition[i]*180/PI;
					//////////保留2位小数///////
					if(robotState.TargetJointPosition[i]>=0)
					{
						robotState.TargetJointPosition[i] += 0.005;
					}
					else
					{
						robotState.TargetJointPosition[i] -= 0.005;
					}
					temp = (int)(robotState.TargetJointPosition[i]*100);
					robotState.TargetJointPosition[i] = temp / 100.0;
					///////////////////////////
					robotState.JointSpeed[i] = ReadDouble(subOffset+16);
					robotState.JointSpeed[i] = robotState.JointSpeed[i]*180/PI;
				}
				break;
			case 4:
				//解析Cartesian Info包
				robotState.ToolPosition[0] = ReadDouble(streamOffset);
				robotState.ToolPosition[1] = ReadDouble(streamOffset + 8);
				robotState.ToolPosition[2] = ReadDouble(streamOffset + 8*2);
				robotState.ToolOrientation[0] = ReadDouble(streamOffset + 8*3);
				robotState.ToolOrientation[1] = ReadDouble(streamOffset + 8*4);
				robotState.ToolOrientation[2] = ReadDouble(streamOffset + 8*5);
				break;
			case 3:
				//解析Masterboard Data数据包
				int digialOut = (int)splitDataBuffer[streamOffset+7];
				int byteToolOutput = (int)splitDataBuffer[streamOffset + 5];
                int byteDigitalInput = (int)splitDataBuffer[streamOffset + 3];
                int byteToolInput = (int)splitDataBuffer[streamOffset + 1];
				robotState.DigitalOut[0] = (bool)((digialOut & 0x01) >> 0);
				robotState.DigitalOut[1] = (bool)((digialOut & 0x02) >> 1);
				robotState.DigitalOut[2] = (bool)((digialOut & 0x04) >> 2);
				robotState.DigitalOut[3] = (bool)((digialOut & 0x08) >> 3);
				robotState.DigitalOut[4] = (bool)((digialOut & 0x10) >> 4);
				robotState.DigitalOut[5] = (bool)((digialOut & 0x20) >> 5);
				robotState.DigitalOut[6] = (bool)((digialOut & 0x40) >> 6);
				robotState.DigitalOut[7] = (bool)((digialOut & 0x80) >> 7);

				robotState.TO0 = (bool)(((byteToolOutput & 0x01) >> 0));
                robotState.TO1 = (bool)(((byteToolOutput & 0x02) >> 1));
                robotState.TI0 = (bool)(((byteToolInput & 0x01) >> 0));
                robotState.TI1 = (bool)(((byteToolInput & 0x02) >> 1));
				break;
		}
		streamOffset = streamOffset + subPacLength - 5;
	}
	emit OnReceiveData(robotState);
}

void AsySocketClient::DataStreamReader30003_V18(unsigned int streamOffset,unsigned int pacLength)
{
	//由于没有具体的文档说明V18下的数据格式，因此解析空缺
}

void AsySocketClient::DataStreamReader30003_V30(unsigned int streamOffset,unsigned int pacLength)
{
	QByteArray pacArray = splitDataBuffer.mid(streamOffset,pacLength);
	QByteArray pacArrayInverse;
	for(int i = pacArray.length()-1;i>=0;i--)
	{
		pacArrayInverse.append(pacArray[i]);
	}

	robotState.Message_Size = ReadInt(pacArrayInverse, 1040);
    robotState.Time = ReadDouble(pacArrayInverse, 1032);

    robotState.q_target[0] = ReadDouble(pacArrayInverse, 1024);//j0
    robotState.q_target[1] = ReadDouble(pacArrayInverse, 1016);//j1
    robotState.q_target[2] = ReadDouble(pacArrayInverse, 1008);//j2
    robotState.q_target[3] = ReadDouble(pacArrayInverse, 1000);//j3
    robotState.q_target[4] = ReadDouble(pacArrayInverse, 992);//j4
    robotState.q_target[5] = ReadDouble(pacArrayInverse, 984);//j5
    robotState.qd_target[0] = ReadDouble(pacArrayInverse, 976);//j0
    robotState.qd_target[1] = ReadDouble(pacArrayInverse, 968);//j1
    robotState.qd_target[2] = ReadDouble(pacArrayInverse, 960);//j2
    robotState.qd_target[3] = ReadDouble(pacArrayInverse, 952);//j3
    robotState.qd_target[4] = ReadDouble(pacArrayInverse, 944);//j4
    robotState.qd_target[5] = ReadDouble(pacArrayInverse, 936);//j5
    robotState.qdd_target[0] = ReadDouble(pacArrayInverse, 928);//j0
    robotState.qdd_target[1] = ReadDouble(pacArrayInverse, 920);//j1
    robotState.qdd_target[2] = ReadDouble(pacArrayInverse, 912);//j2
    robotState.qdd_target[3] = ReadDouble(pacArrayInverse, 904);//j3
    robotState.qdd_target[4] = ReadDouble(pacArrayInverse, 896);//j4
    robotState.qdd_target[5] = ReadDouble(pacArrayInverse, 888);//j5
    robotState.I_target[0] = ReadDouble(pacArrayInverse, 880);//j0
    robotState.I_target[1] = ReadDouble(pacArrayInverse, 872);//j1
    robotState.I_target[2] = ReadDouble(pacArrayInverse, 864);//j2
    robotState.I_target[3] = ReadDouble(pacArrayInverse, 856);//j3
    robotState.I_target[4] = ReadDouble(pacArrayInverse, 848);//j4
    robotState.I_target[5] = ReadDouble(pacArrayInverse, 840);//j5
    robotState.M_target[0] = ReadDouble(pacArrayInverse, 832);//j0
    robotState.M_target[1] = ReadDouble(pacArrayInverse, 824);//j1
    robotState.M_target[2] = ReadDouble(pacArrayInverse, 816);//j2
    robotState.M_target[3] = ReadDouble(pacArrayInverse, 808);//j3
    robotState.M_target[4] = ReadDouble(pacArrayInverse, 800);//j4
    robotState.M_target[5] = ReadDouble(pacArrayInverse, 792);//j5

    robotState.q_actual[0] = ReadDouble(pacArrayInverse, 784);//j0
    robotState.q_actual[1] = ReadDouble(pacArrayInverse, 776);//j1
    robotState.q_actual[2] = ReadDouble(pacArrayInverse, 768);//j2
    robotState.q_actual[3] = ReadDouble(pacArrayInverse, 760);//j3
    robotState.q_actual[4] = ReadDouble(pacArrayInverse, 752);//j4
    robotState.q_actual[5] = ReadDouble(pacArrayInverse, 744);//j5
    robotState.qd_actual[0] = ReadDouble(pacArrayInverse, 736);//j0
    robotState.qd_actual[1] = ReadDouble(pacArrayInverse, 728);//j1
    robotState.qd_actual[2] = ReadDouble(pacArrayInverse, 720);//j2
    robotState.qd_actual[3] = ReadDouble(pacArrayInverse, 712);//j3
    robotState.qd_actual[4] = ReadDouble(pacArrayInverse, 704);//j4
    robotState.qd_actual[5] = ReadDouble(pacArrayInverse, 696);//j5
    robotState.I_actual[0] = ReadDouble(pacArrayInverse, 688);//j0
    robotState.I_actual[1] = ReadDouble(pacArrayInverse, 680);//j1
    robotState.I_actual[2] = ReadDouble(pacArrayInverse, 672);//j2
    robotState.I_actual[3] = ReadDouble(pacArrayInverse, 664);//j3
    robotState.I_actual[4] = ReadDouble(pacArrayInverse, 656);//j4
    robotState.I_actual[5] = ReadDouble(pacArrayInverse, 648);//j5
    robotState.I_control[0] = ReadDouble(pacArrayInverse, 640);//j0
    robotState.I_control[1] = ReadDouble(pacArrayInverse, 632);//j1
    robotState.I_control[2] = ReadDouble(pacArrayInverse, 624);//j2
    robotState.I_control[3] = ReadDouble(pacArrayInverse, 616);//j3
    robotState.I_control[4] = ReadDouble(pacArrayInverse, 608);//j4
    robotState.I_control[5] = ReadDouble(pacArrayInverse, 600);//j5

    robotState.Tool_vector_actual[0] = ReadDouble(pacArrayInverse, 592);//x
    robotState.Tool_vector_actual[1] = ReadDouble(pacArrayInverse, 584);//y
    robotState.Tool_vector_actual[2] = ReadDouble(pacArrayInverse, 576);//z
    robotState.Tool_vector_actual[3] = ReadDouble(pacArrayInverse, 568);//rx
    robotState.Tool_vector_actual[4] = ReadDouble(pacArrayInverse, 560);//ry
    robotState.Tool_vector_actual[5] = ReadDouble(pacArrayInverse, 552);//rz
    robotState.TCP_speed_actual[0] = ReadDouble(pacArrayInverse, 544);//x
    robotState.TCP_speed_actual[1] = ReadDouble(pacArrayInverse, 536);//y
    robotState.TCP_speed_actual[2] = ReadDouble(pacArrayInverse, 528);//z
    robotState.TCP_speed_actual[3] = ReadDouble(pacArrayInverse, 520);//rx
    robotState.TCP_speed_actual[4] = ReadDouble(pacArrayInverse, 512);//ry
    robotState.TCP_speed_actual[5] = ReadDouble(pacArrayInverse, 504);//rz
    robotState.TCP_force[0] = ReadDouble(pacArrayInverse, 496);//x
    robotState.TCP_force[1] = ReadDouble(pacArrayInverse, 488);//y
    robotState.TCP_force[2] = ReadDouble(pacArrayInverse, 480);//z
    robotState.TCP_force[3] = ReadDouble(pacArrayInverse, 472);//rx
    robotState.TCP_force[4] = ReadDouble(pacArrayInverse, 464);//ry
    robotState.TCP_force[5] = ReadDouble(pacArrayInverse, 456);//rz
    robotState.Tool_vector_target[0] = ReadDouble(pacArrayInverse, 448);//x
    robotState.Tool_vector_target[1] = ReadDouble(pacArrayInverse, 440);//y
    robotState.Tool_vector_target[2] = ReadDouble(pacArrayInverse, 432);//z
    robotState.Tool_vector_target[3] = ReadDouble(pacArrayInverse, 424);//rx
    robotState.Tool_vector_target[4] = ReadDouble(pacArrayInverse, 416);//ry
    robotState.Tool_vector_target[5] = ReadDouble(pacArrayInverse, 408);//rz
    robotState.TCP_speed_target[0] = ReadDouble(pacArrayInverse, 400);//x
    robotState.TCP_speed_target[1] = ReadDouble(pacArrayInverse, 392);//y
    robotState.TCP_speed_target[2] = ReadDouble(pacArrayInverse, 384);//z
    robotState.TCP_speed_target[3] = ReadDouble(pacArrayInverse, 376);//rx
    robotState.TCP_speed_target[4] = ReadDouble(pacArrayInverse, 368);//ry
    robotState.TCP_speed_target[5] = ReadDouble(pacArrayInverse, 360);//rz


    robotState.Digital_input_bits = ReadDouble(pacArrayInverse, 352);
    robotState.Motor_temperatures[0] = ReadDouble(pacArrayInverse, 344);//j0
    robotState.Motor_temperatures[1] = ReadDouble(pacArrayInverse, 336);//j1
    robotState.Motor_temperatures[2] = ReadDouble(pacArrayInverse, 328);//j2
    robotState.Motor_temperatures[3] = ReadDouble(pacArrayInverse, 320);//j3
    robotState.Motor_temperatures[4] = ReadDouble(pacArrayInverse, 312);//j4
    robotState.Motor_temperatures[5] = ReadDouble(pacArrayInverse, 304);//j5
    robotState.Controller_Timer = ReadDouble(pacArrayInverse, 296);
    robotState.Test_value = ReadDouble(pacArrayInverse, 288);


    robotState.Robot_mode = ReadDouble(pacArrayInverse, 280);

    robotState.Joint_Modes[0] = ReadDouble(pacArrayInverse, 272);//j0
    robotState.Joint_Modes[1] = ReadDouble(pacArrayInverse, 264);//j1
    robotState.Joint_Modes[2] = ReadDouble(pacArrayInverse, 256);//j2
    robotState.Joint_Modes[3] = ReadDouble(pacArrayInverse, 248);//j3
    robotState.Joint_Modes[4] = ReadDouble(pacArrayInverse, 240);//j4
    robotState.Joint_Modes[5] = ReadDouble(pacArrayInverse, 232);//j5

    robotState.Safty_Mode = ReadDouble(pacArrayInverse, 224);


    robotState.UR_Only1[0] = ReadDouble(pacArrayInverse, 216);
    robotState.UR_Only1[1] = ReadDouble(pacArrayInverse, 208);
    robotState.UR_Only1[2] = ReadDouble(pacArrayInverse, 200);
    robotState.UR_Only1[3] = ReadDouble(pacArrayInverse, 192);
    robotState.UR_Only1[4] = ReadDouble(pacArrayInverse, 184);
    robotState.UR_Only1[5] = ReadDouble(pacArrayInverse, 176);

    robotState.Tool_Accelerometer_values[0] = ReadDouble(pacArrayInverse, 168);
    robotState.Tool_Accelerometer_values[1] = ReadDouble(pacArrayInverse, 160);
    robotState.Tool_Accelerometer_values[2] = ReadDouble(pacArrayInverse, 152);

    robotState.UR_Only2[0] = ReadDouble(pacArrayInverse, 144);
    robotState.UR_Only2[1] = ReadDouble(pacArrayInverse, 136);
    robotState.UR_Only2[2] = ReadDouble(pacArrayInverse, 128);
    robotState.UR_Only2[3] = ReadDouble(pacArrayInverse, 120);
    robotState.UR_Only2[4] = ReadDouble(pacArrayInverse, 112);
    robotState.UR_Only2[5] = ReadDouble(pacArrayInverse, 104);

    robotState.Speed_scaling = ReadDouble(pacArrayInverse, 96);
    robotState.Linear_momentum_norm = ReadDouble(pacArrayInverse, 88);

    robotState.UR_Only3 = ReadDouble(pacArrayInverse, 80);
    robotState.UR_Only4 = ReadDouble(pacArrayInverse, 72);

    robotState.V_main = ReadDouble(pacArrayInverse, 64);
    robotState.V_robot = ReadDouble(pacArrayInverse, 56);
    robotState.I_robot = ReadDouble(pacArrayInverse, 48);
    robotState.V_actual[0] = ReadDouble(pacArrayInverse, 40);//j0
    robotState.V_actual[1] = ReadDouble(pacArrayInverse, 32);//j1
    robotState.V_actual[2] = ReadDouble(pacArrayInverse, 24);//j2
    robotState.V_actual[3] = ReadDouble(pacArrayInverse, 16);//j3
    robotState.V_actual[4] = ReadDouble(pacArrayInverse, 8);//j4
    robotState.V_actual[5] = ReadDouble(pacArrayInverse, 0);//j5

    //"数据翻译"
    robotState.Robot_mode_Int = unsigned short(robotState.Robot_mode);
    switch (robotState.Robot_mode_Int)
    {
        case 0:
            robotState.Robot_mode_String = "ROBOT_MODE_DISCONNECTED";
            break;
        case 1:
            robotState.Robot_mode_String = "ROBOT_MODE_CONFIRM_SAFTY";
            break;
        case 2:
            robotState.Robot_mode_String = "ROBOT_MODE_BOOTING";
            break;
        case 3:
            robotState.Robot_mode_String = "ROBOT_MODE_POWER_OFF";
            break;
        case 4:
            robotState.Robot_mode_String = "ROBOT_MODE_POWER_ON";
            break;
        case 5:
            robotState.Robot_mode_String = "ROBOT_MODE_IDLE";
            break;
        case 6:
            robotState.Robot_mode_String = "ROBOT_MODE_BACKDRIVE";
            break;
        case 7:
            robotState.Robot_mode_String = "ROBOT_MODE_RUNNING";
            break;
        default:
            robotState.Robot_mode_String = "";
            break;
    }

    robotState.Safty_mode_Int = unsigned short(robotState.Safty_Mode);
    switch (robotState.Safty_mode_Int)
    {
        case 1:
            robotState.Safty_mode_String = "SAFETY_MODE_NORMAL";
            break;
        case 2:
            robotState.Safty_mode_String = "SAFETY_MODE_REDUCED";
            break;
        case 3:
            robotState.Safty_mode_String = "SAFETY_MODE_PROTECTIVE_STOP";
            break;
        case 4:
            robotState.Safty_mode_String = "SAFETY_MODE_RECOVERY";
            break;
        case 5:
            robotState.Safty_mode_String = "SAFETY_MODE_SAFEGUARD_STOP";
            break;
        case 6:
            robotState.Safty_mode_String = "SAFETY_MODE_SYSTEM_EMERGENCY_STOP";
            break;
        case 7:
            robotState.Safty_mode_String = "SAFETY_MODE_ROBOT_EMERGENCY_STOP";
            break;
        case 8:
            robotState.Safty_mode_String = "SAFETY_MODE_ROBOT_VIOLATION";
            break;
        case 9:
            robotState.Safty_mode_String = "SAFETY_MODE_FAULT";
            break;
        default:
            break;
    }

    for (int i = 0; i < 6; i++)
    {
        robotState.Joint_Modes_Int[i] = unsigned short(robotState.Joint_Modes[i]);

        switch (robotState.Joint_Modes_Int[i])
        {
            case 236:
                robotState.Joint_Modes_String[i] = "JOINT_SHUTTING_DOWN_MODE";
                break;
            case 237:
                robotState.Joint_Modes_String[i] = "JOINT_PART_D_CALIBRATION_MODE";
                break;
            case 238:
                robotState.Joint_Modes_String[i] = "JOINT_BACKDRIVE_MODE";
                break;
            case 239:
                robotState.Joint_Modes_String[i] = "JOINT_POWER_OFF_MODE";
                break;
            case 245:
                robotState.Joint_Modes_String[i] = "JOINT_NOT_RESPONSE_MODE";
                break;
            case 246:
                robotState.Joint_Modes_String[i] = "JOINT_MOTOR_INITIALISATION_MODE";
                break;
            case 247:
                robotState.Joint_Modes_String[i] = "JOINT_BOOTING_MODE";
                break;
            case 248:
                robotState.Joint_Modes_String[i] = "JOINT_DEAD_COMMUNICATION_MODE";
                break;
            case 249:
                robotState.Joint_Modes_String[i] = "JOINT_BOOTLOADER_MODE";
                break;
            case 250:
                robotState.Joint_Modes_String[i] = "JOINT_CALIBRATION_MODE";
                break;
            case 252:
                robotState.Joint_Modes_String[i] = "JOINT_FAULT_MODE";
                break;
            case 253:
                robotState.Joint_Modes_String[i] = "JOINT_RUNNING_MODE";
                break;
            case 255:
                robotState.Joint_Modes_String[i] = "JOINT_IDLE_MODE";
                break;
            default:
                robotState.Joint_Modes_String[i] = "";
                break;
        }
    }

    //数据复制
    double joint0;
    double joint1;
    double joint2;
    double joint3;
    double joint4;
    double joint5;

    double speed0;
    double speed1;
    double speed2;
    double speed3;
    double speed4;
    double speed5;

    double x;
    double y;
    double z;
    double rx;
    double ry;
    double rz;

    joint0 = robotState.q_actual[0];
    joint0 = ConvertToAngle(joint0);

    joint1 = robotState.q_actual[1];
    joint1 = ConvertToAngle(joint1);

    joint2 = robotState.q_actual[2];
    joint2 = ConvertToAngle(joint2);

    joint3 = robotState.q_actual[3];
    joint3 = ConvertToAngle(joint3);

    joint4 = robotState.q_actual[4];
    joint4 = ConvertToAngle(joint4);

    joint5 = robotState.q_actual[5];
    joint5 = ConvertToAngle(joint5);

    speed0 = robotState.qd_actual[0];
    speed0 = ConvertToAngle(speed0);

    speed1 = robotState.qd_actual[1];
    speed1 = ConvertToAngle(speed1);

    speed2 = robotState.qd_actual[2];
    speed2 = ConvertToAngle(speed2);

    speed3 = robotState.qd_actual[3];
    speed3 = ConvertToAngle(speed3);

    speed4 = robotState.qd_actual[4];
    speed4 = ConvertToAngle(speed4);

    speed5 = robotState.qd_actual[5];
    speed5 = ConvertToAngle(speed5);

    x = robotState.Tool_vector_actual[0];
    x = MathRound(x);
    y = robotState.Tool_vector_actual[1];
    y = MathRound(y);
    z = robotState.Tool_vector_actual[2];
    z = MathRound(z);
    rx = robotState.Tool_vector_actual[3];
    rx = MathRound(rx);
    ry = robotState.Tool_vector_actual[4];
    ry = MathRound(ry);
    rz = robotState.Tool_vector_actual[5];
    rz = MathRound(rz);

    robotState.JointPosition[0] = joint0;
    robotState.JointPosition[1] = joint1;
    robotState.JointPosition[2] = joint2;
    robotState.JointPosition[3] = joint3;
    robotState.JointPosition[4] = joint4;
    robotState.JointPosition[5] = joint5;

    robotState.JointSpeed[0] = speed0;
    robotState.JointSpeed[1] = speed1;
    robotState.JointSpeed[2] = speed2;
    robotState.JointSpeed[3] = speed3;
    robotState.JointSpeed[4] = speed4;
    robotState.JointSpeed[5] = speed5;

    robotState.ToolPosition[0] = x;
    robotState.ToolPosition[1] = y;
    robotState.ToolPosition[2] = z;
    robotState.ToolOrientation[0] = rx;
    robotState.ToolOrientation[1] = ry;
    robotState.ToolOrientation[2] = rz;

    robotState.RobotMode = robotState.Robot_mode_Int;

    int DiOutputValue = int(robotState.Digital_output_bits);
    robotState.DigitalOut[7] = bool(((DiOutputValue & 0x80) >> 7));
    robotState.DigitalOut[6] = bool(((DiOutputValue & 0x40) >> 6));
    robotState.DigitalOut[5] = bool(((DiOutputValue & 0x20) >> 5));
    robotState.DigitalOut[4] = bool(((DiOutputValue & 0x10) >> 4));
    robotState.DigitalOut[3] = bool(((DiOutputValue & 0x08) >> 3));
    robotState.DigitalOut[2] = bool(((DiOutputValue & 0x04) >> 2));
    robotState.DigitalOut[1] = bool(((DiOutputValue & 0x02) >> 1));
    robotState.DigitalOut[0] = bool(((DiOutputValue & 0x01) >> 0));

    robotState.TO0 = bool(((DiOutputValue & 0x10000) >> 16));
    robotState.TO1 = bool(((DiOutputValue & 0x20000) >> 17));

    int DiInputValue = int(robotState.Digital_input_bits);
    robotState.TI0 = bool(((DiInputValue & 0x10000) >> 16));
    robotState.TI1 = bool(((DiInputValue & 0x20000) >> 17));

    robotState.IsEmergencyStopped = (robotState.Safty_mode_Int == 6 || robotState.Safty_mode_Int == 7) ? true : false;
    robotState.IsSecurityStopped = (robotState.Safty_mode_Int == 3 || robotState.Safty_mode_Int == 5) ? true : false;
    robotState.IsPowerOnRobot = (robotState.Robot_mode_Int == 4) ? true : false;

	emit OnReceiveData(robotState);
}

void AsySocketClient::DataStreamReader30003_V32(unsigned int streamOffset,unsigned int pacLength)
{
	//QByteArray RtData ;
	//for (int i = 0; i < dataLengthV32; i++)
	//{
	//	RtData[i] = splitDataBuffer[streamOffset + i];
	//}
	//QByteArray pacArray = RtData.mid(streamOffset,pacLength);
	//QByteArray pacArrayInverse;
	//for(int i = pacArray.length()-1;i>=0;i--)
	//{
	//	pacArrayInverse.append(pacArray[i]);
	//}
	QByteArray pacArray = splitDataBuffer.mid(streamOffset,pacLength);
	if(0<pacArray.size())
	{
		QByteArray pacArrayInverse;
		for(int i = pacArray.length()-1;i>=0;i--)
		{
			pacArrayInverse.append(pacArray[i]);
		}

		robotState.Message_Size = ReadInt(pacArrayInverse, 1040 + 16);
		robotState.Time = ReadDouble(pacArrayInverse, 1032+16);

		robotState.q_target[0] = ReadDouble(pacArrayInverse, 1024 + 16);//j0
		robotState.q_target[1] = ReadDouble(pacArrayInverse, 1016 + 16);//j1
		robotState.q_target[2] = ReadDouble(pacArrayInverse, 1008 + 16);//j2
		robotState.q_target[3] = ReadDouble(pacArrayInverse, 1000 + 16);//j3
		robotState.q_target[4] = ReadDouble(pacArrayInverse, 992 + 16);//j4
		robotState.q_target[5] = ReadDouble(pacArrayInverse, 984 + 16);//j5
		robotState.qd_target[0] = ReadDouble(pacArrayInverse, 976 + 16);//j0
		robotState.qd_target[1] = ReadDouble(pacArrayInverse, 968 + 16);//j1
		robotState.qd_target[2] = ReadDouble(pacArrayInverse, 960 + 16);//j2
		robotState.qd_target[3] = ReadDouble(pacArrayInverse, 952 + 16);//j3
		robotState.qd_target[4] = ReadDouble(pacArrayInverse, 944 + 16);//j4
		robotState.qd_target[5] = ReadDouble(pacArrayInverse, 936 + 16);//j5
		robotState.qdd_target[0] = ReadDouble(pacArrayInverse, 928 + 16);//j0
		robotState.qdd_target[1] = ReadDouble(pacArrayInverse, 920 + 16);//j1
		robotState.qdd_target[2] = ReadDouble(pacArrayInverse, 912 + 16);//j2
		robotState.qdd_target[3] = ReadDouble(pacArrayInverse, 904 + 16);//j3
		robotState.qdd_target[4] = ReadDouble(pacArrayInverse, 896 + 16);//j4
		robotState.qdd_target[5] = ReadDouble(pacArrayInverse, 888 + 16);//j5
		robotState.I_target[0] = ReadDouble(pacArrayInverse, 880 + 16);//j0
		robotState.I_target[1] = ReadDouble(pacArrayInverse, 872 + 16);//j1
		robotState.I_target[2] = ReadDouble(pacArrayInverse, 864 + 16);//j2
		robotState.I_target[3] = ReadDouble(pacArrayInverse, 856 + 16);//j3
		robotState.I_target[4] = ReadDouble(pacArrayInverse, 848 + 16);//j4
		robotState.I_target[5] = ReadDouble(pacArrayInverse, 840 + 16);//j5
		robotState.M_target[0] = ReadDouble(pacArrayInverse, 832 + 16);//j0
		robotState.M_target[1] = ReadDouble(pacArrayInverse, 824 + 16);//j1
		robotState.M_target[2] = ReadDouble(pacArrayInverse, 816 + 16);//j2
		robotState.M_target[3] = ReadDouble(pacArrayInverse, 808 + 16);//j3
		robotState.M_target[4] = ReadDouble(pacArrayInverse, 800 + 16);//j4
		robotState.M_target[5] = ReadDouble(pacArrayInverse, 792 + 16);//j5

		robotState.q_actual[0] = ReadDouble(pacArrayInverse, 784 + 16);//j0
		robotState.q_actual[1] = ReadDouble(pacArrayInverse, 776 + 16);//j1
		robotState.q_actual[2] = ReadDouble(pacArrayInverse, 768 + 16);//j2
		robotState.q_actual[3] = ReadDouble(pacArrayInverse, 760 + 16);//j3
		robotState.q_actual[4] = ReadDouble(pacArrayInverse, 752 + 16);//j4
		robotState.q_actual[5] = ReadDouble(pacArrayInverse, 744 + 16);//j5
		robotState.qd_actual[0] = ReadDouble(pacArrayInverse, 736 + 16);//j0
		robotState.qd_actual[1] = ReadDouble(pacArrayInverse, 728 + 16);//j1
		robotState.qd_actual[2] = ReadDouble(pacArrayInverse, 720 + 16);//j2
		robotState.qd_actual[3] = ReadDouble(pacArrayInverse, 712 + 16);//j3
		robotState.qd_actual[4] = ReadDouble(pacArrayInverse, 704 + 16);//j4
		robotState.qd_actual[5] = ReadDouble(pacArrayInverse, 696 + 16);//j5
		robotState.I_actual[0] = ReadDouble(pacArrayInverse, 688 + 16);//j0
		robotState.I_actual[1] = ReadDouble(pacArrayInverse, 680 + 16);//j1
		robotState.I_actual[2] = ReadDouble(pacArrayInverse, 672 + 16);//j2
		robotState.I_actual[3] = ReadDouble(pacArrayInverse, 664 + 16);//j3
		robotState.I_actual[4] = ReadDouble(pacArrayInverse, 656 + 16);//j4
		robotState.I_actual[5] = ReadDouble(pacArrayInverse, 648 + 16);//j5
		robotState.I_control[0] = ReadDouble(pacArrayInverse, 640 + 16);//j0
		robotState.I_control[1] = ReadDouble(pacArrayInverse, 632 + 16);//j1
		robotState.I_control[2] = ReadDouble(pacArrayInverse, 624 + 16);//j2
		robotState.I_control[3] = ReadDouble(pacArrayInverse, 616 + 16);//j3
		robotState.I_control[4] = ReadDouble(pacArrayInverse, 608 + 16);//j4
		robotState.I_control[5] = ReadDouble(pacArrayInverse, 600 + 16);//j5

		robotState.Tool_vector_actual[0] = ReadDouble(pacArrayInverse, 592 + 16);//x
		robotState.Tool_vector_actual[1] = ReadDouble(pacArrayInverse, 584 + 16);//y
		robotState.Tool_vector_actual[2] = ReadDouble(pacArrayInverse, 576 + 16);//z
		robotState.Tool_vector_actual[3] = ReadDouble(pacArrayInverse, 568 + 16);//rx
		robotState.Tool_vector_actual[4] = ReadDouble(pacArrayInverse, 560 + 16);//ry
		robotState.Tool_vector_actual[5] = ReadDouble(pacArrayInverse, 552 + 16);//rz
		robotState.TCP_speed_actual[0] = ReadDouble(pacArrayInverse, 544 + 16);//x
		robotState.TCP_speed_actual[1] = ReadDouble(pacArrayInverse, 536 + 16);//y
		robotState.TCP_speed_actual[2] = ReadDouble(pacArrayInverse, 528 + 16);//z
		robotState.TCP_speed_actual[3] = ReadDouble(pacArrayInverse, 520 + 16);//rx
		robotState.TCP_speed_actual[4] = ReadDouble(pacArrayInverse, 512 + 16);//ry
		robotState.TCP_speed_actual[5] = ReadDouble(pacArrayInverse, 504 + 16);//rz
		robotState.TCP_force[0] = ReadDouble(pacArrayInverse, 496 + 16);//x
		robotState.TCP_force[1] = ReadDouble(pacArrayInverse, 488 + 16);//y
		robotState.TCP_force[2] = ReadDouble(pacArrayInverse, 480 + 16);//z
		robotState.TCP_force[3] = ReadDouble(pacArrayInverse, 472 + 16);//rx
		robotState.TCP_force[4] = ReadDouble(pacArrayInverse, 464 + 16);//ry
		robotState.TCP_force[5] = ReadDouble(pacArrayInverse, 456 + 16);//rz
		robotState.Tool_vector_target[0] = ReadDouble(pacArrayInverse, 448 + 16);//x
		robotState.Tool_vector_target[1] = ReadDouble(pacArrayInverse, 440 + 16);//y
		robotState.Tool_vector_target[2] = ReadDouble(pacArrayInverse, 432 + 16);//z
		robotState.Tool_vector_target[3] = ReadDouble(pacArrayInverse, 424 + 16);//rx
		robotState.Tool_vector_target[4] = ReadDouble(pacArrayInverse, 416 + 16);//ry
		robotState.Tool_vector_target[5] = ReadDouble(pacArrayInverse, 408 + 16);//rz
		robotState.TCP_speed_target[0] = ReadDouble(pacArrayInverse, 400 + 16);//x
		robotState.TCP_speed_target[1] = ReadDouble(pacArrayInverse, 392 + 16);//y
		robotState.TCP_speed_target[2] = ReadDouble(pacArrayInverse, 384 + 16);//z
		robotState.TCP_speed_target[3] = ReadDouble(pacArrayInverse, 376 + 16);//rx
		robotState.TCP_speed_target[4] = ReadDouble(pacArrayInverse, 368 + 16);//ry
		robotState.TCP_speed_target[5] = ReadDouble(pacArrayInverse, 360 + 16);//rz


		robotState.Digital_input_bits = ReadDouble(pacArrayInverse, 352 + 16);
		robotState.Motor_temperatures[0] = ReadDouble(pacArrayInverse, 344 + 16);//j0
		robotState.Motor_temperatures[1] = ReadDouble(pacArrayInverse, 336 + 16);//j1
		robotState.Motor_temperatures[2] = ReadDouble(pacArrayInverse, 328 + 16);//j2
		robotState.Motor_temperatures[3] = ReadDouble(pacArrayInverse, 320 + 16);//j3
		robotState.Motor_temperatures[4] = ReadDouble(pacArrayInverse, 312 + 16);//j4
		robotState.Motor_temperatures[5] = ReadDouble(pacArrayInverse, 304 + 16);//j5
		robotState.Controller_Timer = ReadDouble(pacArrayInverse, 296 + 16);
		robotState.Test_value = ReadDouble(pacArrayInverse, 288 + 16);


		robotState.Robot_mode = ReadDouble(pacArrayInverse, 280 + 16);

		robotState.Joint_Modes[0] = ReadDouble(pacArrayInverse, 272 + 16);//j0
		robotState.Joint_Modes[1] = ReadDouble(pacArrayInverse, 264 + 16);//j1
		robotState.Joint_Modes[2] = ReadDouble(pacArrayInverse, 256 + 16);//j2
		robotState.Joint_Modes[3] = ReadDouble(pacArrayInverse, 248 + 16);//j3
		robotState.Joint_Modes[4] = ReadDouble(pacArrayInverse, 240 + 16);//j4
		robotState.Joint_Modes[5] = ReadDouble(pacArrayInverse, 232 + 16);//j5

		robotState.Safty_Mode = ReadDouble(pacArrayInverse, 224 + 16);


		robotState.UR_Only1[0] = ReadDouble(pacArrayInverse, 216 + 16);
		robotState.UR_Only1[1] = ReadDouble(pacArrayInverse, 208 + 16);
		robotState.UR_Only1[2] = ReadDouble(pacArrayInverse, 200 + 16);
		robotState.UR_Only1[3] = ReadDouble(pacArrayInverse, 192 + 16);
		robotState.UR_Only1[4] = ReadDouble(pacArrayInverse, 184 + 16);
		robotState.UR_Only1[5] = ReadDouble(pacArrayInverse, 176 + 16);

		robotState.Tool_Accelerometer_values[0] = ReadDouble(pacArrayInverse, 168 + 16);
		robotState.Tool_Accelerometer_values[1] = ReadDouble(pacArrayInverse, 160 + 16);
		robotState.Tool_Accelerometer_values[2] = ReadDouble(pacArrayInverse, 152 + 16);

		robotState.UR_Only2[0] = ReadDouble(pacArrayInverse, 144 + 16);
		robotState.UR_Only2[1] = ReadDouble(pacArrayInverse, 136 + 16);
		robotState.UR_Only2[2] = ReadDouble(pacArrayInverse, 128 + 16);
		robotState.UR_Only2[3] = ReadDouble(pacArrayInverse, 120 + 16);
		robotState.UR_Only2[4] = ReadDouble(pacArrayInverse, 112 + 16);
		robotState.UR_Only2[5] = ReadDouble(pacArrayInverse, 104 + 16);

		robotState.Speed_scaling = ReadDouble(pacArrayInverse, 96 + 16);
		robotState.Linear_momentum_norm = ReadDouble(pacArrayInverse, 88 + 16);

		robotState.UR_Only3 = ReadDouble(pacArrayInverse, 80 + 16);
		robotState.UR_Only4 = ReadDouble(pacArrayInverse, 72 + 16);

		robotState.V_main = ReadDouble(pacArrayInverse, 64 + 16);
		robotState.V_robot = ReadDouble(pacArrayInverse, 56 + 16);
		robotState.I_robot = ReadDouble(pacArrayInverse, 48 + 16);
		robotState.V_actual[0] = ReadDouble(pacArrayInverse, 40 + 16);//j0
		robotState.V_actual[1] = ReadDouble(pacArrayInverse, 32 + 16);//j1
		robotState.V_actual[2] = ReadDouble(pacArrayInverse, 24 + 16);//j2
		robotState.V_actual[3] = ReadDouble(pacArrayInverse, 16 + 16);//j3
		robotState.V_actual[4] = ReadDouble(pacArrayInverse, 8 + 16);//j4
		robotState.V_actual[5] = ReadDouble(pacArrayInverse, 0 + 16);//j5

		robotState.Digital_output_bits = ReadDouble(pacArrayInverse, 8);
		robotState.Program_state = ReadDouble(pacArrayInverse, 0);

		//"数据翻译"
		robotState.Robot_mode_Int = unsigned short(robotState.Robot_mode);
		switch (robotState.Robot_mode_Int)
		{
		case 0:
			robotState.Robot_mode_String = "ROBOT_MODE_DISCONNECTED";
			break;
		case 1:
			robotState.Robot_mode_String = "ROBOT_MODE_CONFIRM_SAFTY";
			break;
		case 2:
			robotState.Robot_mode_String = "ROBOT_MODE_BOOTING";
			break;
		case 3:
			robotState.Robot_mode_String = "ROBOT_MODE_POWER_OFF";
			break;
		case 4:
			robotState.Robot_mode_String = "ROBOT_MODE_POWER_ON";
			break;
		case 5:
			robotState.Robot_mode_String = "ROBOT_MODE_IDLE";
			break;
		case 6:
			robotState.Robot_mode_String = "ROBOT_MODE_BACKDRIVE";
			break;
		case 7:
			robotState.Robot_mode_String = "ROBOT_MODE_RUNNING";
			break;
		default:
			robotState.Robot_mode_String = "";
			break;
		}

		robotState.Safty_mode_Int = unsigned short(robotState.Safty_Mode);
		switch (robotState.Safty_mode_Int)
		{
		case 1:
			robotState.Safty_mode_String = "SAFETY_MODE_NORMAL";
			break;
		case 2:
			robotState.Safty_mode_String = "SAFETY_MODE_REDUCED";
			break;
		case 3:
			robotState.Safty_mode_String = "SAFETY_MODE_PROTECTIVE_STOP";
			break;
		case 4:
			robotState.Safty_mode_String = "SAFETY_MODE_RECOVERY";
			break;
		case 5:
			robotState.Safty_mode_String = "SAFETY_MODE_SAFEGUARD_STOP";
			break;
		case 6:
			robotState.Safty_mode_String = "SAFETY_MODE_SYSTEM_EMERGENCY_STOP";
			break;
		case 7:
			robotState.Safty_mode_String = "SAFETY_MODE_ROBOT_EMERGENCY_STOP";
			break;
		case 8:
			robotState.Safty_mode_String = "SAFETY_MODE_ROBOT_VIOLATION";
			break;
		case 9:
			robotState.Safty_mode_String = "SAFETY_MODE_FAULT";
			break;
		default:
			break;
		}

		for (int i = 0; i < 6; i++)
		{
			robotState.Joint_Modes_Int[i] = unsigned short(robotState.Joint_Modes[i]);

			switch (robotState.Joint_Modes_Int[i])
			{
			case 236:
				robotState.Joint_Modes_String[i] = "JOINT_SHUTTING_DOWN_MODE";
				break;
			case 237:
				robotState.Joint_Modes_String[i] = "JOINT_PART_D_CALIBRATION_MODE";
				break;
			case 238:
				robotState.Joint_Modes_String[i] = "JOINT_BACKDRIVE_MODE";
				break;
			case 239:
				robotState.Joint_Modes_String[i] = "JOINT_POWER_OFF_MODE";
				break;
			case 245:
				robotState.Joint_Modes_String[i] = "JOINT_NOT_RESPONSE_MODE";
				break;
			case 246:
				robotState.Joint_Modes_String[i] = "JOINT_MOTOR_INITIALISATION_MODE";
				break;
			case 247:
				robotState.Joint_Modes_String[i] = "JOINT_BOOTING_MODE";
				break;
			case 248:
				robotState.Joint_Modes_String[i] = "JOINT_DEAD_COMMUNICATION_MODE";
				break;
			case 249:
				robotState.Joint_Modes_String[i] = "JOINT_BOOTLOADER_MODE";
				break;
			case 250:
				robotState.Joint_Modes_String[i] = "JOINT_CALIBRATION_MODE";
				break;
			case 252:
				robotState.Joint_Modes_String[i] = "JOINT_FAULT_MODE";
				break;
			case 253:
				robotState.Joint_Modes_String[i] = "JOINT_RUNNING_MODE";
				break;
			case 255:
				robotState.Joint_Modes_String[i] = "JOINT_IDLE_MODE";
				break;
			default:
				robotState.Joint_Modes_String[i] = "";
				break;
			}
		}

		//数据复制
		double joint0;
		double joint1;
		double joint2;
		double joint3;
		double joint4;
		double joint5;

		double speed0;
		double speed1;
		double speed2;
		double speed3;
		double speed4;
		double speed5;

		double x;
		double y;
		double z;
		double rx;
		double ry;
		double rz;

		joint0 = robotState.q_actual[0];
		joint0 = ConvertToAngle(joint0);

		joint1 = robotState.q_actual[1];
		joint1 = ConvertToAngle(joint1);

		joint2 = robotState.q_actual[2];
		joint2 = ConvertToAngle(joint2);

		joint3 = robotState.q_actual[3];
		joint3 = ConvertToAngle(joint3);

		joint4 = robotState.q_actual[4];
		joint4 = ConvertToAngle(joint4);

		joint5 = robotState.q_actual[5];
		joint5 = ConvertToAngle(joint5);

		speed0 = robotState.qd_actual[0];
		speed0 = ConvertToAngle(speed0);

		speed1 = robotState.qd_actual[1];
		speed1 = ConvertToAngle(speed1);

		speed2 = robotState.qd_actual[2];
		speed2 = ConvertToAngle(speed2);

		speed3 = robotState.qd_actual[3];
		speed3 = ConvertToAngle(speed3);

		speed4 = robotState.qd_actual[4];
		speed4 = ConvertToAngle(speed4);

		speed5 = robotState.qd_actual[5];
		speed5 = ConvertToAngle(speed5);

		x = robotState.Tool_vector_actual[0];
		x = MathRound(x);
		y = robotState.Tool_vector_actual[1];
		y = MathRound(y);
		z = robotState.Tool_vector_actual[2];
		z = MathRound(z);
		rx = robotState.Tool_vector_actual[3];
		rx = MathRound(rx);
		ry = robotState.Tool_vector_actual[4];
		ry = MathRound(ry);
		rz = robotState.Tool_vector_actual[5];
		rz = MathRound(rz);

		robotState.JointPosition[0] = joint0;
		robotState.JointPosition[1] = joint1;
		robotState.JointPosition[2] = joint2;
		robotState.JointPosition[3] = joint3;
		robotState.JointPosition[4] = joint4;
		robotState.JointPosition[5] = joint5;

		if(abs(joint1)<=0.2)
		{
			int i=1;
			//TIGS_LOG_INFO("DataStreamReader30003_V35 error;");
		}

		robotState.JointSpeed[0] = speed0;
		robotState.JointSpeed[1] = speed1;
		robotState.JointSpeed[2] = speed2;
		robotState.JointSpeed[3] = speed3;
		robotState.JointSpeed[4] = speed4;
		robotState.JointSpeed[5] = speed5;

		robotState.ToolPosition[0] = x;
		robotState.ToolPosition[1] = y;
		robotState.ToolPosition[2] = z;
		robotState.ToolOrientation[0] = rx;
		robotState.ToolOrientation[1] = ry;
		robotState.ToolOrientation[2] = rz;

		robotState.RobotMode = robotState.Robot_mode_Int;

		int DiOutputValue = int(robotState.Digital_output_bits);
		robotState.DigitalOut[7] = bool(((DiOutputValue & 0x80) >> 7));
		robotState.DigitalOut[6] = bool(((DiOutputValue & 0x40) >> 6));
		robotState.DigitalOut[5] = bool(((DiOutputValue & 0x20) >> 5));
		robotState.DigitalOut[4] = bool(((DiOutputValue & 0x10) >> 4));
		robotState.DigitalOut[3] = bool(((DiOutputValue & 0x08) >> 3));
		robotState.DigitalOut[2] = bool(((DiOutputValue & 0x04) >> 2));
		robotState.DigitalOut[1] = bool(((DiOutputValue & 0x02) >> 1));
		robotState.DigitalOut[0] = bool(((DiOutputValue & 0x01) >> 0));

		robotState.TO0 = bool(((DiOutputValue & 0x10000) >> 16));
		robotState.TO1 = bool(((DiOutputValue & 0x20000) >> 17));

		int DiInputValue = int(robotState.Digital_input_bits);
		robotState.DigitalIn[7] = bool(((DiInputValue & 0x80) >> 7));
		robotState.DigitalIn[6] = bool(((DiInputValue & 0x40) >> 6));
		robotState.DigitalIn[5] = bool(((DiInputValue & 0x20) >> 5));
		robotState.DigitalIn[4] = bool(((DiInputValue & 0x10) >> 4));
		robotState.DigitalIn[3] = bool(((DiInputValue & 0x08) >> 3));
		robotState.DigitalIn[2] = bool(((DiInputValue & 0x04) >> 2));
		robotState.DigitalIn[1] = bool(((DiInputValue & 0x02) >> 1));
		robotState.DigitalIn[0] = bool(((DiInputValue & 0x01) >> 0));

		robotState.TI0 = bool(((DiInputValue & 0x10000) >> 16));
		robotState.TI1 = bool(((DiInputValue & 0x20000) >> 17));

		robotState.IsEmergencyStopped = (robotState.Safty_mode_Int == 6 || robotState.Safty_mode_Int == 7) ? true : false;
		robotState.IsSecurityStopped = (robotState.Safty_mode_Int == 3 || robotState.Safty_mode_Int == 5) ? true : false;
		robotState.IsPowerOnRobot = (robotState.Robot_mode_Int == 4) ? true : false;

		emit OnReceiveData(robotState);
	}

}

void AsySocketClient::DataStreamReader30003_V35(unsigned int streamOffset,unsigned int pacLength)
{
	mutex.lock();
	//QByteArray RtData ;
	//for (int i = 0; i < dataLengthV32; i++)
	//{
	//	RtData[i] = splitDataBuffer[streamOffset + i];
	//}
	//QByteArray pacArray = RtData.mid(streamOffset,pacLength);
	//QByteArray pacArrayInverse;
	//for(int i = pacArray.length()-1;i>=0;i--)
	//{
	//	pacArrayInverse.append(pacArray[i]);
	//}
	QByteArray pacArray = splitDataBuffer.mid(streamOffset,pacLength);
	if(0<pacArray.size())
	{
		QByteArray pacArrayInverse;
		for(int i = pacArray.length()-1;i>=0;i--)
		{
			pacArrayInverse.append(pacArray[i]);
		}

		robotState.Message_Size = ReadInt(pacArrayInverse, 1040 + 16);
		robotState.Time = ReadDouble(pacArrayInverse, 1032+16);

		robotState.q_target[0] = ReadDouble(pacArrayInverse, 1024 + 16);//j0
		robotState.q_target[1] = ReadDouble(pacArrayInverse, 1016 + 16);//j1
		robotState.q_target[2] = ReadDouble(pacArrayInverse, 1008 + 16);//j2
		robotState.q_target[3] = ReadDouble(pacArrayInverse, 1000 + 16);//j3
		robotState.q_target[4] = ReadDouble(pacArrayInverse, 992 + 16);//j4
		robotState.q_target[5] = ReadDouble(pacArrayInverse, 984 + 16);//j5
		robotState.qd_target[0] = ReadDouble(pacArrayInverse, 976 + 16);//j0
		robotState.qd_target[1] = ReadDouble(pacArrayInverse, 968 + 16);//j1
		robotState.qd_target[2] = ReadDouble(pacArrayInverse, 960 + 16);//j2
		robotState.qd_target[3] = ReadDouble(pacArrayInverse, 952 + 16);//j3
		robotState.qd_target[4] = ReadDouble(pacArrayInverse, 944 + 16);//j4
		robotState.qd_target[5] = ReadDouble(pacArrayInverse, 936 + 16);//j5
		robotState.qdd_target[0] = ReadDouble(pacArrayInverse, 928 + 16);//j0
		robotState.qdd_target[1] = ReadDouble(pacArrayInverse, 920 + 16);//j1
		robotState.qdd_target[2] = ReadDouble(pacArrayInverse, 912 + 16);//j2
		robotState.qdd_target[3] = ReadDouble(pacArrayInverse, 904 + 16);//j3
		robotState.qdd_target[4] = ReadDouble(pacArrayInverse, 896 + 16);//j4
		robotState.qdd_target[5] = ReadDouble(pacArrayInverse, 888 + 16);//j5
		robotState.I_target[0] = ReadDouble(pacArrayInverse, 880 + 16);//j0
		robotState.I_target[1] = ReadDouble(pacArrayInverse, 872 + 16);//j1
		robotState.I_target[2] = ReadDouble(pacArrayInverse, 864 + 16);//j2
		robotState.I_target[3] = ReadDouble(pacArrayInverse, 856 + 16);//j3
		robotState.I_target[4] = ReadDouble(pacArrayInverse, 848 + 16);//j4
		robotState.I_target[5] = ReadDouble(pacArrayInverse, 840 + 16);//j5
		robotState.M_target[0] = ReadDouble(pacArrayInverse, 832 + 16);//j0
		robotState.M_target[1] = ReadDouble(pacArrayInverse, 824 + 16);//j1
		robotState.M_target[2] = ReadDouble(pacArrayInverse, 816 + 16);//j2
		robotState.M_target[3] = ReadDouble(pacArrayInverse, 808 + 16);//j3
		robotState.M_target[4] = ReadDouble(pacArrayInverse, 800 + 16);//j4
		robotState.M_target[5] = ReadDouble(pacArrayInverse, 792 + 16);//j5

		robotState.q_actual[0] = ReadDouble(pacArrayInverse, 784 + 16);//j0
		robotState.q_actual[1] = ReadDouble(pacArrayInverse, 776 + 16);//j1
		robotState.q_actual[2] = ReadDouble(pacArrayInverse, 768 + 16);//j2
		robotState.q_actual[3] = ReadDouble(pacArrayInverse, 760 + 16);//j3
		robotState.q_actual[4] = ReadDouble(pacArrayInverse, 752 + 16);//j4
		robotState.q_actual[5] = ReadDouble(pacArrayInverse, 744 + 16);//j5
		robotState.qd_actual[0] = ReadDouble(pacArrayInverse, 736 + 16);//j0
		robotState.qd_actual[1] = ReadDouble(pacArrayInverse, 728 + 16);//j1
		robotState.qd_actual[2] = ReadDouble(pacArrayInverse, 720 + 16);//j2
		robotState.qd_actual[3] = ReadDouble(pacArrayInverse, 712 + 16);//j3
		robotState.qd_actual[4] = ReadDouble(pacArrayInverse, 704 + 16);//j4
		robotState.qd_actual[5] = ReadDouble(pacArrayInverse, 696 + 16);//j5
		robotState.I_actual[0] = ReadDouble(pacArrayInverse, 688 + 16);//j0
		robotState.I_actual[1] = ReadDouble(pacArrayInverse, 680 + 16);//j1
		robotState.I_actual[2] = ReadDouble(pacArrayInverse, 672 + 16);//j2
		robotState.I_actual[3] = ReadDouble(pacArrayInverse, 664 + 16);//j3
		robotState.I_actual[4] = ReadDouble(pacArrayInverse, 656 + 16);//j4
		robotState.I_actual[5] = ReadDouble(pacArrayInverse, 648 + 16);//j5
		robotState.I_control[0] = ReadDouble(pacArrayInverse, 640 + 16);//j0
		robotState.I_control[1] = ReadDouble(pacArrayInverse, 632 + 16);//j1
		robotState.I_control[2] = ReadDouble(pacArrayInverse, 624 + 16);//j2
		robotState.I_control[3] = ReadDouble(pacArrayInverse, 616 + 16);//j3
		robotState.I_control[4] = ReadDouble(pacArrayInverse, 608 + 16);//j4
		robotState.I_control[5] = ReadDouble(pacArrayInverse, 600 + 16);//j5

		robotState.Tool_vector_actual[0] = ReadDouble(pacArrayInverse, 592 + 16);//x
		robotState.Tool_vector_actual[1] = ReadDouble(pacArrayInverse, 584 + 16);//y
		robotState.Tool_vector_actual[2] = ReadDouble(pacArrayInverse, 576 + 16);//z
		robotState.Tool_vector_actual[3] = ReadDouble(pacArrayInverse, 568 + 16);//rx
		robotState.Tool_vector_actual[4] = ReadDouble(pacArrayInverse, 560 + 16);//ry
		robotState.Tool_vector_actual[5] = ReadDouble(pacArrayInverse, 552 + 16);//rz
		robotState.TCP_speed_actual[0] = ReadDouble(pacArrayInverse, 544 + 16);//x
		robotState.TCP_speed_actual[1] = ReadDouble(pacArrayInverse, 536 + 16);//y
		robotState.TCP_speed_actual[2] = ReadDouble(pacArrayInverse, 528 + 16);//z
		robotState.TCP_speed_actual[3] = ReadDouble(pacArrayInverse, 520 + 16);//rx
		robotState.TCP_speed_actual[4] = ReadDouble(pacArrayInverse, 512 + 16);//ry
		robotState.TCP_speed_actual[5] = ReadDouble(pacArrayInverse, 504 + 16);//rz
		robotState.TCP_force[0] = ReadDouble(pacArrayInverse, 496 + 16);//x
		robotState.TCP_force[1] = ReadDouble(pacArrayInverse, 488 + 16);//y
		robotState.TCP_force[2] = ReadDouble(pacArrayInverse, 480 + 16);//z
		robotState.TCP_force[3] = ReadDouble(pacArrayInverse, 472 + 16);//rx
		robotState.TCP_force[4] = ReadDouble(pacArrayInverse, 464 + 16);//ry
		robotState.TCP_force[5] = ReadDouble(pacArrayInverse, 456 + 16);//rz
		robotState.Tool_vector_target[0] = ReadDouble(pacArrayInverse, 448 + 16);//x
		robotState.Tool_vector_target[1] = ReadDouble(pacArrayInverse, 440 + 16);//y
		robotState.Tool_vector_target[2] = ReadDouble(pacArrayInverse, 432 + 16);//z
		robotState.Tool_vector_target[3] = ReadDouble(pacArrayInverse, 424 + 16);//rx
		robotState.Tool_vector_target[4] = ReadDouble(pacArrayInverse, 416 + 16);//ry
		robotState.Tool_vector_target[5] = ReadDouble(pacArrayInverse, 408 + 16);//rz
		robotState.TCP_speed_target[0] = ReadDouble(pacArrayInverse, 400 + 16);//x
		robotState.TCP_speed_target[1] = ReadDouble(pacArrayInverse, 392 + 16);//y
		robotState.TCP_speed_target[2] = ReadDouble(pacArrayInverse, 384 + 16);//z
		robotState.TCP_speed_target[3] = ReadDouble(pacArrayInverse, 376 + 16);//rx
		robotState.TCP_speed_target[4] = ReadDouble(pacArrayInverse, 368 + 16);//ry
		robotState.TCP_speed_target[5] = ReadDouble(pacArrayInverse, 360 + 16);//rz


		robotState.Digital_input_bits = ReadDouble(pacArrayInverse, 352 + 16);
		robotState.Motor_temperatures[0] = ReadDouble(pacArrayInverse, 344 + 16);//j0
		robotState.Motor_temperatures[1] = ReadDouble(pacArrayInverse, 336 + 16);//j1
		robotState.Motor_temperatures[2] = ReadDouble(pacArrayInverse, 328 + 16);//j2
		robotState.Motor_temperatures[3] = ReadDouble(pacArrayInverse, 320 + 16);//j3
		robotState.Motor_temperatures[4] = ReadDouble(pacArrayInverse, 312 + 16);//j4
		robotState.Motor_temperatures[5] = ReadDouble(pacArrayInverse, 304 + 16);//j5
		robotState.Controller_Timer = ReadDouble(pacArrayInverse, 296 + 16);
		robotState.Test_value = ReadDouble(pacArrayInverse, 288 + 16);


		robotState.Robot_mode = ReadDouble(pacArrayInverse, 280 + 16);

		robotState.Joint_Modes[0] = ReadDouble(pacArrayInverse, 272 + 16);//j0
		robotState.Joint_Modes[1] = ReadDouble(pacArrayInverse, 264 + 16);//j1
		robotState.Joint_Modes[2] = ReadDouble(pacArrayInverse, 256 + 16);//j2
		robotState.Joint_Modes[3] = ReadDouble(pacArrayInverse, 248 + 16);//j3
		robotState.Joint_Modes[4] = ReadDouble(pacArrayInverse, 240 + 16);//j4
		robotState.Joint_Modes[5] = ReadDouble(pacArrayInverse, 232 + 16);//j5

		robotState.Safty_Mode = ReadDouble(pacArrayInverse, 224 + 16);


		robotState.UR_Only1[0] = ReadDouble(pacArrayInverse, 216 + 16);
		robotState.UR_Only1[1] = ReadDouble(pacArrayInverse, 208 + 16);
		robotState.UR_Only1[2] = ReadDouble(pacArrayInverse, 200 + 16);
		robotState.UR_Only1[3] = ReadDouble(pacArrayInverse, 192 + 16);
		robotState.UR_Only1[4] = ReadDouble(pacArrayInverse, 184 + 16);
		robotState.UR_Only1[5] = ReadDouble(pacArrayInverse, 176 + 16);

		robotState.Tool_Accelerometer_values[0] = ReadDouble(pacArrayInverse, 168 + 16);
		robotState.Tool_Accelerometer_values[1] = ReadDouble(pacArrayInverse, 160 + 16);
		robotState.Tool_Accelerometer_values[2] = ReadDouble(pacArrayInverse, 152 + 16);

		robotState.UR_Only2[0] = ReadDouble(pacArrayInverse, 144 + 16);
		robotState.UR_Only2[1] = ReadDouble(pacArrayInverse, 136 + 16);
		robotState.UR_Only2[2] = ReadDouble(pacArrayInverse, 128 + 16);
		robotState.UR_Only2[3] = ReadDouble(pacArrayInverse, 120 + 16);
		robotState.UR_Only2[4] = ReadDouble(pacArrayInverse, 112 + 16);
		robotState.UR_Only2[5] = ReadDouble(pacArrayInverse, 104 + 16);

		robotState.Speed_scaling = ReadDouble(pacArrayInverse, 96 + 16);
		robotState.Linear_momentum_norm = ReadDouble(pacArrayInverse, 88 + 16);

		robotState.UR_Only3 = ReadDouble(pacArrayInverse, 80 + 16);
		robotState.UR_Only4 = ReadDouble(pacArrayInverse, 72 + 16);

		robotState.V_main = ReadDouble(pacArrayInverse, 64 + 16);
		robotState.V_robot = ReadDouble(pacArrayInverse, 56 + 16);
		robotState.I_robot = ReadDouble(pacArrayInverse, 48 + 16);
		robotState.V_actual[0] = ReadDouble(pacArrayInverse, 40 + 16);//j0
		robotState.V_actual[1] = ReadDouble(pacArrayInverse, 32 + 16);//j1
		robotState.V_actual[2] = ReadDouble(pacArrayInverse, 24 + 16);//j2
		robotState.V_actual[3] = ReadDouble(pacArrayInverse, 16 + 16);//j3
		robotState.V_actual[4] = ReadDouble(pacArrayInverse, 8 + 16);//j4
		robotState.V_actual[5] = ReadDouble(pacArrayInverse, 0 + 16);//j5

		robotState.Digital_output_bits = ReadDouble(pacArrayInverse, 8);
		robotState.Program_state = ReadDouble(pacArrayInverse, 0);

		//"数据翻译"
		robotState.Robot_mode_Int = unsigned short(robotState.Robot_mode);
		switch (robotState.Robot_mode_Int)
		{
		case 0:
			robotState.Robot_mode_String = "ROBOT_MODE_DISCONNECTED";
			break;
		case 1:
			robotState.Robot_mode_String = "ROBOT_MODE_CONFIRM_SAFTY";
			break;
		case 2:
			robotState.Robot_mode_String = "ROBOT_MODE_BOOTING";
			break;
		case 3:
			robotState.Robot_mode_String = "ROBOT_MODE_POWER_OFF";
			break;
		case 4:
			robotState.Robot_mode_String = "ROBOT_MODE_POWER_ON";
			break;
		case 5:
			robotState.Robot_mode_String = "ROBOT_MODE_IDLE";
			break;
		case 6:
			robotState.Robot_mode_String = "ROBOT_MODE_BACKDRIVE";
			break;
		case 7:
			robotState.Robot_mode_String = "ROBOT_MODE_RUNNING";
			break;
		default:
			robotState.Robot_mode_String = "";
			break;
		}

		robotState.Safty_mode_Int = unsigned short(robotState.Safty_Mode);
		switch (robotState.Safty_mode_Int)
		{
		case 1:
			robotState.Safty_mode_String = "SAFETY_MODE_NORMAL";
			break;
		case 2:
			robotState.Safty_mode_String = "SAFETY_MODE_REDUCED";
			break;
		case 3:
			robotState.Safty_mode_String = "SAFETY_MODE_PROTECTIVE_STOP";
			break;
		case 4:
			robotState.Safty_mode_String = "SAFETY_MODE_RECOVERY";
			break;
		case 5:
			robotState.Safty_mode_String = "SAFETY_MODE_SAFEGUARD_STOP";
			break;
		case 6:
			robotState.Safty_mode_String = "SAFETY_MODE_SYSTEM_EMERGENCY_STOP";
			break;
		case 7:
			robotState.Safty_mode_String = "SAFETY_MODE_ROBOT_EMERGENCY_STOP";
			break;
		case 8:
			robotState.Safty_mode_String = "SAFETY_MODE_ROBOT_VIOLATION";
			break;
		case 9:
			robotState.Safty_mode_String = "SAFETY_MODE_FAULT";
			break;
		default:
			break;
		}

		for (int i = 0; i < 6; i++)
		{
			robotState.Joint_Modes_Int[i] = unsigned short(robotState.Joint_Modes[i]);

			switch (robotState.Joint_Modes_Int[i])
			{
			case 236:
				robotState.Joint_Modes_String[i] = "JOINT_SHUTTING_DOWN_MODE";
				break;
			case 237:
				robotState.Joint_Modes_String[i] = "JOINT_PART_D_CALIBRATION_MODE";
				break;
			case 238:
				robotState.Joint_Modes_String[i] = "JOINT_BACKDRIVE_MODE";
				break;
			case 239:
				robotState.Joint_Modes_String[i] = "JOINT_POWER_OFF_MODE";
				break;
			case 245:
				robotState.Joint_Modes_String[i] = "JOINT_NOT_RESPONSE_MODE";
				break;
			case 246:
				robotState.Joint_Modes_String[i] = "JOINT_MOTOR_INITIALISATION_MODE";
				break;
			case 247:
				robotState.Joint_Modes_String[i] = "JOINT_BOOTING_MODE";
				break;
			case 248:
				robotState.Joint_Modes_String[i] = "JOINT_DEAD_COMMUNICATION_MODE";
				break;
			case 249:
				robotState.Joint_Modes_String[i] = "JOINT_BOOTLOADER_MODE";
				break;
			case 250:
				robotState.Joint_Modes_String[i] = "JOINT_CALIBRATION_MODE";
				break;
			case 252:
				robotState.Joint_Modes_String[i] = "JOINT_FAULT_MODE";
				break;
			case 253:
				robotState.Joint_Modes_String[i] = "JOINT_RUNNING_MODE";
				break;
			case 255:
				robotState.Joint_Modes_String[i] = "JOINT_IDLE_MODE";
				break;
			default:
				robotState.Joint_Modes_String[i] = "";
				break;
			}
		}

		//数据复制
		double joint0;
		double joint1;
		double joint2;
		double joint3;
		double joint4;
		double joint5;

		double speed0;
		double speed1;
		double speed2;
		double speed3;
		double speed4;
		double speed5;

		double x;
		double y;
		double z;
		double rx;
		double ry;
		double rz;

		joint0 = robotState.q_actual[0];
		joint0 = ConvertToAngle(joint0);

		joint1 = robotState.q_actual[1];
		joint1 = ConvertToAngle(joint1);

		joint2 = robotState.q_actual[2];
		joint2 = ConvertToAngle(joint2);

		joint3 = robotState.q_actual[3];
		joint3 = ConvertToAngle(joint3);

		joint4 = robotState.q_actual[4];
		joint4 = ConvertToAngle(joint4);

		joint5 = robotState.q_actual[5];
		joint5 = ConvertToAngle(joint5);

		speed0 = robotState.qd_actual[0];
		speed0 = ConvertToAngle(speed0);

		speed1 = robotState.qd_actual[1];
		speed1 = ConvertToAngle(speed1);

		speed2 = robotState.qd_actual[2];
		speed2 = ConvertToAngle(speed2);

		speed3 = robotState.qd_actual[3];
		speed3 = ConvertToAngle(speed3);

		speed4 = robotState.qd_actual[4];
		speed4 = ConvertToAngle(speed4);

		speed5 = robotState.qd_actual[5];
		speed5 = ConvertToAngle(speed5);

		x = robotState.Tool_vector_actual[0];
		x = MathRound(x);
		y = robotState.Tool_vector_actual[1];
		y = MathRound(y);
		z = robotState.Tool_vector_actual[2];
		z = MathRound(z);
		rx = robotState.Tool_vector_actual[3];
		rx = MathRound(rx);
		ry = robotState.Tool_vector_actual[4];
		ry = MathRound(ry);
		rz = robotState.Tool_vector_actual[5];
		rz = MathRound(rz);

		robotState.JointPosition[0] = joint0;
		robotState.JointPosition[1] = joint1;
		robotState.JointPosition[2] = joint2;
		robotState.JointPosition[3] = joint3;
		robotState.JointPosition[4] = joint4;
		robotState.JointPosition[5] = joint5;

		if(abs(joint1)<=0.2)
		{
			int i=1;
			//TIGS_LOG_INFO("DataStreamReader30003_V35 error;");
		}

		robotState.JointSpeed[0] = speed0;
		robotState.JointSpeed[1] = speed1;
		robotState.JointSpeed[2] = speed2;
		robotState.JointSpeed[3] = speed3;
		robotState.JointSpeed[4] = speed4;
		robotState.JointSpeed[5] = speed5;

		robotState.ToolPosition[0] = x;
		robotState.ToolPosition[1] = y;
		robotState.ToolPosition[2] = z;
		robotState.ToolOrientation[0] = rx;
		robotState.ToolOrientation[1] = ry;
		robotState.ToolOrientation[2] = rz;

		robotState.RobotMode = robotState.Robot_mode_Int;

		int DiOutputValue = int(robotState.Digital_output_bits);
		robotState.DigitalOut[7] = bool(((DiOutputValue & 0x80) >> 7));
		robotState.DigitalOut[6] = bool(((DiOutputValue & 0x40) >> 6));
		robotState.DigitalOut[5] = bool(((DiOutputValue & 0x20) >> 5));
		robotState.DigitalOut[4] = bool(((DiOutputValue & 0x10) >> 4));
		robotState.DigitalOut[3] = bool(((DiOutputValue & 0x08) >> 3));
		robotState.DigitalOut[2] = bool(((DiOutputValue & 0x04) >> 2));
		robotState.DigitalOut[1] = bool(((DiOutputValue & 0x02) >> 1));
		robotState.DigitalOut[0] = bool(((DiOutputValue & 0x01) >> 0));

		robotState.TO0 = bool(((DiOutputValue & 0x10000) >> 16));
		robotState.TO1 = bool(((DiOutputValue & 0x20000) >> 17));

		int DiInputValue = int(robotState.Digital_input_bits);
		robotState.DigitalIn[7] = bool(((DiInputValue & 0x80) >> 7));
		robotState.DigitalIn[6] = bool(((DiInputValue & 0x40) >> 6));
		robotState.DigitalIn[5] = bool(((DiInputValue & 0x20) >> 5));
		robotState.DigitalIn[4] = bool(((DiInputValue & 0x10) >> 4));
		robotState.DigitalIn[3] = bool(((DiInputValue & 0x08) >> 3));
		robotState.DigitalIn[2] = bool(((DiInputValue & 0x04) >> 2));
		robotState.DigitalIn[1] = bool(((DiInputValue & 0x02) >> 1));
		robotState.DigitalIn[0] = bool(((DiInputValue & 0x01) >> 0));

		robotState.TI0 = bool(((DiInputValue & 0x10000) >> 16));
		robotState.TI1 = bool(((DiInputValue & 0x20000) >> 17));

		robotState.IsEmergencyStopped = (robotState.Safty_mode_Int == 6 || robotState.Safty_mode_Int == 7) ? true : false;
		robotState.IsSecurityStopped = (robotState.Safty_mode_Int == 3 || robotState.Safty_mode_Int == 5) ? true : false;
		robotState.IsPowerOnRobot = (robotState.Robot_mode_Int == 4) ? true : false;

		emit OnReceiveData(robotState);
	}
	mutex.unlock();
}

QString AsySocketClient::GetCurrentDateTime()
{
	QDateTime current_date_time = QDateTime::currentDateTime();
	QString current_date = current_date_time.toString("yyyy-MM-dd hh:mm:ss");
	return current_date;
}

double AsySocketClient::ReadDouble(unsigned int streamOffset)
{
	double resultData;
	QByteArray joint;
	joint = splitDataBuffer.mid(streamOffset,8);
	QByteArray jointConvert;
	jointConvert.resize(8);
	//转换字节高低位顺序
	for (int i = 0; i < 8; i++)
	{
		jointConvert[i] = joint[std::abs(7 - i)];
	}
	memcpy(&resultData,jointConvert,sizeof(double));
	//////////保留5位小数///////
	//if(resultData>=0)
	//{
	//	resultData += 0.000005;
	//}
	//else
	//{
	//	resultData -= 0.000005;
	//}
	//int temp = (int)(resultData*100000);
	//resultData = temp / 100000.0;
	///////////////////////////
	return resultData;
}

double AsySocketClient::ReadDouble(QByteArray streamArray, unsigned int streamOffset)
{
	double resultData;
	QByteArray joint;
	joint = streamArray.mid(streamOffset,8);
	memcpy(&resultData,joint,sizeof(double));
	//////////保留5位小数///////
	//if(resultData>=0)
	//{
	//	resultData += 0.000005;
	//}
	//else
	//{
	//	resultData -= 0.000005;
	//}
	//long temp = (long)(resultData*100000);
	//resultData = temp / 100000.0;
	///////////////////////////
	return resultData;
}

unsigned int AsySocketClient::ReadInt(unsigned int streamOffset)
{
	unsigned int resultData;

	resultData = splitDataBuffer[streamOffset+3] & 0x000000FF;
	resultData |= ((splitDataBuffer[streamOffset+2] << 8) & 0x0000FF00);   
	resultData |= ((splitDataBuffer[streamOffset+1] << 16) & 0x00FF0000);    
	resultData |= ((splitDataBuffer[streamOffset+0] << 24) & 0xFF000000); 

	return resultData;
}

unsigned int AsySocketClient::ReadInt(QByteArray streamArray, unsigned int streamOffset)
{
	unsigned int resultData;

	//resultData = streamArray[streamOffset+3] & 0x000000FF;
	//resultData |= ((streamArray[streamOffset+2] << 8) & 0x0000FF00);   
	//resultData |= ((streamArray[streamOffset+1] << 16) & 0x00FF0000);    
	//resultData |= ((streamArray[streamOffset+0] << 24) & 0xFF000000); 

	resultData = streamArray[streamOffset+0] & 0x000000FF;
	resultData |= ((streamArray[streamOffset+1] << 8) & 0x0000FF00);   
	resultData |= ((streamArray[streamOffset+2] << 16) & 0x00FF0000);    
	resultData |= ((streamArray[streamOffset+3] << 24) & 0xFF000000); 

	return resultData;
}

bool AsySocketClient::ReadBool(unsigned int streamOffset)
{
	bool resultData;

	resultData = (bool)splitDataBuffer[streamOffset];

	return resultData;
}

bool AsySocketClient::ReadBool(QByteArray streamArray, unsigned int streamOffset)
{
	bool resultData;

	resultData = (bool)streamArray[streamOffset];

	return resultData;
}

void AsySocketClient::SendStream(QString sendString)
{
	socket->write(sendString.toLatin1(),sendString.length());
}

double AsySocketClient::ConvertToAngle(double inputValue)
{
	double resultValue;
	resultValue = inputValue*180/PI;
	//////////保留2位小数///////
	if(resultValue>=0)
	{
		resultValue += 0.005;
	}
	else
	{
		resultValue -= 0.005;
	}
	int temp = (int)(resultValue*100);
	resultValue = temp / 100.0;
	return resultValue;
}

double AsySocketClient::MathRound(double inputValue)
{
	double resultData;
	resultData = inputValue;
	//////////保留5位小数///////
	if(resultData>=0)
	{
		resultData += 0.000005;
	}
	else
	{
		resultData -= 0.000005;
	}
	int temp = (int)(resultData*100000);
	resultData = temp / 100000.0;
	///////////////////////////
	return resultData;
}
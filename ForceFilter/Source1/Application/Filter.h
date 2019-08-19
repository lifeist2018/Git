#ifndef FORCE_FILTER
#define FORCE_FILTER

#include "RobotController.h"
#include <math.h>
#include <QThread>
#include <QTimer>

#define Threshold  0.4
#define Count     12
#define Threshold_1  8
#define Threshold_2  20

using namespace std;

class ForceFilter : public QObject
{
	Q_OBJECT
public:
	ForceFilter();
	~ForceFilter();
	void GetForce(double force[6]);

private:
	RobotController * m_RobotController;
	QThread m_Thread;
	QTimer *m_FilterTimer;
	double m_ForceIn[6];
	double m_ForceOut[6];
	double m_Value[6];
	double m_newValue[6];
	int m_Count[6];
	void EliminateJitterFilter();
	void NoneFilter();
	void LowPassFilter();
	void GetForceIn();

private slots:
	void slotFilterTimerDone();
};

#endif
#include "Filter.h"


ForceFilter::ForceFilter ()
{
	m_RobotController=RobotController::instance();
	this->m_FilterTimer=new QTimer();
	this->m_FilterTimer->setInterval(8);
	memset(m_Count,0,sizeof(m_Count));

	connect(this->m_FilterTimer, SIGNAL(timeout()), this, SLOT(slotFilterTimerDone()));
	connect(&m_Thread, &QThread::finished, this, &QObject::deleteLater);
	m_Thread.start();
	this->m_FilterTimer->start();

}

ForceFilter::~ForceFilter ()
{

}

void ForceFilter::GetForce(double force[6])
{
	for(int i=0;i<6;i++)
	{
		force[i]=m_ForceOut[i];
	}
}

void ForceFilter::GetForceIn()
{
	m_RobotController->GetTcpForce(m_ForceIn);
}

void ForceFilter::EliminateJitterFilter()
{
	for(int i=0;i<6;i++)
	{
		if(abs(m_ForceOut[i]-m_ForceIn[i])>Threshold)
		{
			m_Count[i]++;
			if(m_Count[i]>=Count) 
			{
				m_ForceOut[i]=m_ForceIn[i];
				m_Count[i]=0;
			}
		}
	}
}

void ForceFilter::NoneFilter()
{
	for(int i=0;i<6;i++)
	{
		m_ForceOut[i]=m_ForceIn[i];
	}
}

void ForceFilter::LowPassFilter()
{
	int num_x=0;
    float k_x=0.2;
    int out_flag=0;
    int in_flag=0;
	for(int i=0;i<6;i++)
	{
		if(m_ForceOut[i]-m_ForceIn[i]>0)
		{
			out_flag=1;
		}
		else
		{
			out_flag=0;
		}
		if(out_flag==in_flag)
		{
			if(abs(m_ForceOut[i]-m_ForceIn[i])>Threshold_1)
			{
				num_x=num_x+5;
			}
			if(num_x>=Threshold_2)
			{
				k_x=k_x+0.2;
			}
		}
		else
		{
			num_x=0;
			k_x=0.2;
			in_flag=out_flag;
		}
		if(k_x>0.95)
		{
			k_x=0.95;
		}
		m_ForceOut[i]=(1-k_x)*m_ForceIn[i]+k_x*m_ForceOut[i];
	}
}

void ForceFilter::slotFilterTimerDone()
{
	GetForceIn();
	/*EliminateJitterFilter();*/
	/*NoneFilter();*/
	LowPassFilter();
}
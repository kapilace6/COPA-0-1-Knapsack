#include <iostream>
#include <algorithm>
#include <list>
#include <vector>
#include <iterator>
#include <functional>
#include <time.h>
#include <chrono>
#include <cstdlib>
using namespace std;

struct triple
{
	long long int set;				//Set denotes which Elements are in the Subset
	double w;					//Weight of the Triple
	double p;					//Profit of the Triple

	//Struct Constructor
	triple() : set(0),
		w(0.0),
		p(0.0)
	{}

	//Comparison Operator Overloadings
	bool operator< (const triple &t) const
	{ return (w < t.w); }

	bool operator> (const triple &t) const
	{ return (w > t.w); }
};

void merge_lists(vector<triple> &A, vector<triple> &B,
					vector< pair<double, double> > &V)
{
	vector<triple> T_p, Tcopy;
	triple t;

	long long int v1s = V.size() >> 1, v2s = V.size() - v1s;

	//Initialisation for A
	t.set = 0, t.w = t.p = 0;
	A.push_back(t);

	//Sort A in Non-Increasing Order
	for (long long int i = 0; i < v1s; ++i)
	{
		T_p.clear();
		Tcopy.clear();

		//Add Elements to Subset (Triple) ti
		//Add ti to T_p
		for (long long int j = 0; j < (long long int)A.size(); ++j)
		{
			t.set = A[j].set + (1 << i);
			t.w = A[j].w + V[i].first;
			t.p = A[j].p + V[i].second;

			T_p.push_back(t);
		}

		//Merge A, T_p
		merge(A.begin(), A.end(), T_p.begin(), T_p.end(), back_inserter(Tcopy));
		A = Tcopy;
	}

	//Initialisation for B
	t.set = 0, t.w = t.p = 0;
	B.push_back(t);

	//Sort B in Non-Increasing Order
	for (long long int i = 0; i < v2s; ++i)
	{
		T_p.clear();
		Tcopy.clear();

		//Add Elements to Subset (Triple) ti
		//Add ti to T_p
		for (long long int j = 0; j < (long long int)B.size(); ++j)
		{
			t.set = B[j].set + (1 << i);
			t.w = B[j].w + V[i + v1s].first;
			t.p = B[j].p + V[i + v1s].second;

			T_p.push_back(t);
		}

		//Merge B, T_p
		merge(B.begin(), B.end(), T_p.begin(), T_p.end(), back_inserter(Tcopy), greater<>());
		B = Tcopy;
	}
}

void maxScan(vector<triple> &B, vector< pair<double, long long int> > &maxB)
{
	long long int Bsize = B.size();
	maxB[Bsize - 1].first = B[Bsize - 1].p;
	maxB[Bsize - 1].second = Bsize - 1;
	for (long long int i = Bsize - 2; i >= 0; i--)
	{
		if (B[i].p>maxB[i + 1].first)
		{
			maxB[i].first = B[i].p;
			maxB[i].second = i;
		}
		else
		{
			maxB[i].first = maxB[i + 1].first;
			maxB[i].second = maxB[i + 1].second;
		}
	}
}

long long int generate_sets(vector<triple> &A, vector<triple> &B, const double &c,
						vector< pair<double, long long int> > &maxB, long long int N)
{
	double bestValue = 0;
	pair<long long int, long long int> bestSet;

	long long int i = 0, j = 0;
	while(i < N && j < N)
	{
		if (A[i].w + B[j].w > c)
		{
			++j;

			if (j == N) break;
			else continue;
		}

		if (A[i].p + maxB[j].first > bestValue)
		{
			bestValue = A[i].p + maxB[j].first;
			bestSet = make_pair(A[i].set, maxB[j].second);
		}
		++i;
	}

	return bestValue;
}

long long int dp_knapSack(long long int W, double wt[], double val[], long long int n)
{
	long long int i, w;
	vector< vector<double> > K(n + 1, vector<double>(W + 1));

	// Build table K[][] in bottom up manner 
	for (i = 0; i <= n; i++)
	{
		for (w = 0; w <= W; w++)
		{
			if (i == 0 || w == 0)
				K[i][w] = 0;
			else if (wt[i - 1] <= w)
				K[i][w] = max(val[i - 1] + K[i - 1][w - wt[i - 1]], K[i - 1][w]);
			else
				K[i][w] = K[i - 1][w];
		}
	}
	return K[n][W];
}

int main()
{
	vector<triple> A, B;

	//Input Data
	double c = 0;
	vector< pair<double, double> > V;
	vector<double> wt_arr, p_arr;
	srand(time(0));

	//Input Data
	for (long long int i = 0; i < 40; ++i)
	{
		long long int wt = (rand() % (int)1e7) + 1;
		long long int p = (rand() % (int)1e7) + 1;
		
		c += wt;

		V.push_back(make_pair((double)wt, (double)p));
		//wt_arr.push_back(wt);
		//p_arr.push_back(p);
	}

	c /= 2;
	
	//long long int dpSoln = dp_knapSack(c, &wt_arr[0], &p_arr[0], V.size());
	
	//Computation & Timing
	auto start = chrono::steady_clock::now();

	merge_lists(A, B, V);
	vector< pair<double, long long int> > maxB((long long int)B.size());

	maxScan(B, maxB);
	generate_sets(A, B, c, maxB, (1 << (long long int)(V.size() >> 1)));
	
	auto stop = chrono::steady_clock::now();

	cout << "Computational Time : ";
	cout << (double)(chrono::duration_cast<chrono::nanoseconds>(stop - start).count()) / 1000000.0;
	cout << " ms" << endl;
	cin.get();
	return 0;
}
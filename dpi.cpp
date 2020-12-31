#include "svdpi.h"
#include "Vtb_top__Dpi.h"
#include <stdio.h>
#include <list>
#include <random>

extern void driver(int);

int cnt;
const int MAX=10;
std::list<int> expected_data;

typedef std::mt19937 rng_type;
std::uniform_int_distribution<int>udist(0, 1'000'000);
rng_type rng;

void dpic_init(){
    printf("init\n");
    cnt = 0;
    expected_data.clear();
    rng.seed(11);
}

int drive(){

    cnt++;

    int r = udist(rng);
    driver(r);
    expected_data.push_back(r+1);
    
    if(cnt < MAX){
        return 1;
    } else {
        printf("\nEnd\n");
        return 0;
    }

}

void monitor(int ot_data){
    int val = expected_data.front();
    expected_data.pop_front();
    if (val == ot_data){
        printf("\nMatch %0d", ot_data);
    } else {
        printf("\nMismatch");
    }
}

/*
 Code based on:
 http://www.cplusplus.com/reference/algorithm/next_permutation/
 and some other bits
 */

#include <iostream>
#include <algorithm>
#include <map>
#include <time.h>
#include <limits.h>
using namespace std;

map< int, int >  nm_freqs;

void initFreqs(int numberOfElements){
    int nm_elements;
    int nm_index_min;
    int nm_index_max;
    nm_elements = ((numberOfElements-1)*(numberOfElements-1)*(numberOfElements-1))-(numberOfElements-2);
    nm_index_max = (numberOfElements-1)*(numberOfElements-1)*(numberOfElements-1);
    nm_index_min = (numberOfElements-1);
    
    for (int nm_index_i = 0; nm_index_i <= nm_index_min; nm_index_i++) {
        nm_freqs[nm_index_i] = 0;
    }
    
    /*printf("Elements: %d Min: %d Max: %d \n", nm_elements, nm_index_min, nm_index_max);*/
    printf("NM Freqs initialised! [%d][%d->%d] \n", nm_elements, nm_index_min, nm_index_max);
}

void saveFreqs(int numberOfElements){
    int nm_index_min;
    int nm_index_max;
    nm_index_max = (numberOfElements-1)*(numberOfElements-1)*(numberOfElements-1);
    nm_index_min = (numberOfElements-1);
    FILE *file;
    file = fopen("perm9_file.csv","a+");
    fprintf(file,"%s,%s\n","nm","freq");
    
    cout << "Writing out NM freqs.....\n";
    for (int nm_index_j = 0; nm_index_j <= nm_index_max; nm_index_j++) {
        /*printf("printing index %d .....\n",nm_index_j);*/
        fprintf(file,"%d,%d\n",nm_index_j,nm_freqs[nm_index_j]);
    }    
    cout << "Closing file.....\n";
    fclose(file);
    cout << "All done!.....\n";
    cout << endl;
}

int main () {
    time_t begin, end;
    time(&begin); /*record start time of main method*/
	int myints[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15};
    //int myints[] = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}; /*set this to desired size*/
    //int myArrayLength = 15; /*change this to size of myints*/
	int myArrayLength = 15;
    int myArrayLength1 = myArrayLength -1;
    int nm;
    int nm_sqrt;
	int round_counter = 0;
	long long round_print_threshold = 130767436800;
	int message_counter = 0;
    
    std::cout << std::numeric_limits<long long>::max() << std::endl;
    
    initFreqs(myArrayLength);
    
    cout << "Permuting....\n";
    
    sort (myints,myints+myArrayLength);
    
    do {
		round_counter++;
		if(round_counter == round_print_threshold){
			message_counter++;
			cout << " Active message" << message_counter << "..." << endl;
			round_counter = 0;
		}
        nm = 0;
        for(int element_i=0;element_i<myArrayLength1;element_i++){
            nm_sqrt = (myints[element_i] - myints[(element_i+1)]);
            nm += nm_sqrt*nm_sqrt;
        }
        nm_freqs[nm] = nm_freqs[nm] + 1;
		//cout << nm << " increased count..." << endl;
        /*cout << myints[0] << " " << myints[1] << " " << myints[2] << " " << myints[3] << " " << myints[4] << " ==> nm = " << nm << endl;*/
        /*cout << nm << endl;*/
    } while ( next_permutation (myints,myints+myArrayLength) );
    
    saveFreqs(myArrayLength);
    
    time(&end); /*record end time of main method*/
    cout << "The whole joke took " << difftime(end, begin) << " seconds" << endl;
    
    return 0;
}
#include <iostream>
#include <vector>
#include <algorithm>
#include <string>
#include <pthread.h>
#include <semaphore.h>
#include <thread>

/* Checks if the string might be converted to positive integer. */
bool isNumber(const std::string& s) {
	return !s.empty() && std::all_of(s.begin(), s.end(), ::isdigit);
}

/* Checks validity of provided arguments. */
bool checkInputValidity(int argc, char* argv[]) {
	if (argc != 4) {
		std::cout << "Invalid number of arguments! Got: " << argc - 1 << ".\n";
		return false;
	}
	if (!isNumber(argv[1]) || std::stoi(argv[1]) < 1 || std::stoi(argv[1]) > 100) {
		std::cout << "Writers number should be integer in [1; 100]! Got: " << argv[1] << ".\n";
		return false;
	}
	if (!isNumber(argv[2]) || std::stoi(argv[2]) < 1 || std::stoi(argv[2]) > 100) {
		std::cout << "Readers number should be integer in [1; 100]! Got: " << argv[2] << ".\n";
		return false;
	}
	if (!isNumber(argv[3]) || std::stoi(argv[3]) < 5 || std::stoi(argv[3]) > 120) {
		std::cout << "Time of execution should be between 5 and 120 seconds inclusively! Got: " << argv[3] << ".\n";
		return false;
	}
	return true;
}

int write_count = 0, read_count = 0;

/* Semaphores for database acess control. */
sem_t writers_semaphore, available_everyone;

/* Semaphores for readers queue management. */
sem_t change_read_count, change_write_count;

/* Semaphore for console output control. */
sem_t output_semaphore;

/* Database - storage of books.  */
std::vector<std::string> writings;

int writings_number = 1;


/* Writers thread. */
void* writer(void* args) {
	int iterations = 1;
	while (true) {
		std::pair<int, std::string>* converted = (std::pair<int, std::string>*)args; //int - writer number
		srand(time(NULL) + converted->first);
		int to_sleep = rand() % 10;
		std::this_thread::sleep_for(std::chrono::seconds(to_sleep));
		std::string new_book_name = converted->second + "_" + std::to_string(iterations);

		sem_wait(&change_write_count);
		++write_count;
		if (write_count == 1)
			sem_wait(&available_everyone); // Waits for the end of reading - blocks entrance of new readers until writes itself
		sem_post(&change_write_count);
		
		sem_wait(&writers_semaphore); // Blocks collection for all other threads
		
		// WRITING
		int add_time = time(NULL);
		writings.push_back(new_book_name);
		++writings_number;

		sem_post(&writers_semaphore);

		sem_wait(&change_write_count);
		--write_count;
		if (write_count == 0)
			sem_post(&available_everyone); // If the last writer - unlock for readers
		sem_post(&change_write_count);


		sem_wait(&output_semaphore);
		std::cout << "At " + std::to_string(add_time) + " Writer " + std::to_string(converted->first) + " added to the library book named: " + new_book_name + ".\n";
		sem_post(&output_semaphore);
		++iterations;
	}
	return nullptr;
}

/* Readers thread. */
void* reader(void* args) {
	int diff = (int)args;
	while (true) {
		srand((unsigned int)(time(NULL) + diff));
		int to_sleep = rand() % 10;
		std::this_thread::sleep_for(std::chrono::seconds(to_sleep));

		sem_wait(&available_everyone); // Lock availability - to be the first in the queue
		sem_wait(&change_read_count); // Lock counter
		++read_count;
		if (read_count == 1) {
			sem_wait(&writers_semaphore); // If writer is active - wait for it, then lock
		}
		sem_post(&change_read_count);
		sem_post(&available_everyone);

		// READING
		int to_read = rand() % writings_number;
		int read_time = time(NULL);
		std::string readed = writings[to_read];

		sem_wait(&change_read_count);
		--read_count;
		if (read_count == 0)
			sem_post(&writers_semaphore); // If the last readed - then unlock for writers
		sem_post(&change_read_count);

		sem_wait(&output_semaphore);
		std::cout << "At " + std::to_string(read_time) + " Reader " + std::to_string(diff) + " readed the book named: " + readed + ".\n";
		sem_post(&output_semaphore);
	}
	return nullptr;
}

int main(int argc, char* argv[])
{
	// DATA INITIALISATION
	if (!checkInputValidity(argc, argv)) {
		return 0;
	}
	int writers_number = std::stoi(argv[1]);
	int readers_number = std::stoi(argv[2]);
	int total_time = std::stoi(argv[3]);
	writings.push_back("Welcome!");

	// SEMAPHORES INITIALIZATION
	sem_init(&writers_semaphore, false, 1);
	sem_init(&output_semaphore, false, 1);
	sem_init(&change_read_count, false, 1);
	sem_init(&change_write_count, false, 1);
	sem_init(&available_everyone, false, 1);


	// WRITERS THREADS INITIALISATION
	pthread_t* writersid = new pthread_t[writers_number];
	for (int i = 0; i < writers_number; ++i) {
		std::string input = "text_" + std::to_string(i);
		std::pair<int, std::string>* args = new std::pair<int, std::string>(i, input);
		pthread_create(&writersid[i], NULL, writer, args);
	}

	// READERS THREADS INITIALISATION
	pthread_t* readersid = new pthread_t[readers_number];
	for (int i = 0; i < readers_number; ++i) {
		pthread_create(&readersid[i], NULL, reader, (void*)i);
	}

	// EXECUTION
	std::this_thread::sleep_for(std::chrono::seconds(total_time));
}
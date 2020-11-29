#include <iostream>
#include <string>
#include <algorithm>
#include <omp.h>

/* Matrix class. */
struct Matrix {
public:

	/* Empty matrix constructor. */
	Matrix(int n) {
		matrix_size_ = n;
		matrix_ = new short* [n];
		for (int i = 0; i < n; i++)
		{
			matrix_[i] = new short[n];
		}
	}

	/*  Matrix constructor. Recieves array to initialize values. */
	Matrix(int n, int* array) {
		matrix_size_ = n;
		int pos = 0;
		matrix_ = new short* [n];
		for (int i = 0; i < n; i++)
		{
			matrix_[i] = new short[n];
			for (int j = 0; j < n; j++) {
				matrix_[i][j] = array[pos++];
			}
		}
	}

	/* Matrix destructor. */
	~Matrix() {
		delete[] matrix_;
	}

	/* Calculates matrix determinant. */
	int getDeterminant() {
		if (this->matrix_size_ == 1) {
			return matrix_[0][0];
		}
		if (this->matrix_size_ == 2) {
			return matrix_[0][0] * matrix_[1][1] -
				matrix_[1][0] * matrix_[0][1];
		}
		int res = 0;
		for (int i = 0; i < this->matrix_size_; ++i) {
			int sign = i % 2 == 0 ? 1 : -1;
			res += sign * matrix_[0][i] * buildSubmatrix(0, i)->getDeterminant();
		}
		return res;
	}

	/* Prints matrix to the console. */
	void printMatrix() {
		for (int i = 0; i < matrix_size_; ++i) {
			for (int j = 0; j < matrix_size_; ++j) {
				std::cout << matrix_[i][j] << " ";
			}
			std::cout << "\n";
		}
	}

	/* Builds submatrix without row and column with given numbers. */
	Matrix* buildSubmatrix(int excluded_row_num, int excluded_column_num) {
		Matrix* res = new Matrix(this->matrix_size_ - 1);
		for (int i = 0; i < this->matrix_size_ - 1; ++i) {
			int row = i < excluded_row_num ? i : i + 1;
			for (int j = 0; j < this->matrix_size_ - 1; ++j) {
				int column = j < excluded_column_num ? j : j + 1;
				res->matrix_[i][j] = this->matrix_[row][column];
			}
		}
		return res;
	}

private:
	short** matrix_;

	int matrix_size_;
};

/* Calculates algebraical complement for the given matrix element. */
void getAlgebraicalComplement(Matrix& matrix, int row, int column) {
	int sign = (row + column) % 2 == 0 ? 1 : -1;
	int res = sign * matrix.buildSubmatrix(row, column)->getDeterminant();
#pragma omp critical
	std::cout << "Algebraical complement of element (" << row << ", " << column << ") = " << res << "\n";
}

/* Consequently provides coordinates of matrix elements.
* Moves from the left to the right, then changes row. */
struct CoordinateIterator {
public:
	CoordinateIterator(int size) : size_(size) {};
	std::pair<int, int> getCoordinate() {
		std::pair<int, int> res = std::make_pair(first_, second_);
		if (second_ >= size_) {
			if (first_ < size_ - 1) {
				++first_;
				second_ = 1;
				return std::make_pair(first_, 0);
			}
			else {
				return std::make_pair(-1, -1);
			}
		}
		++second_;
		return res;
	}


private:
	int size_;
	int first_ = 0, second_ = 0;
};

/* Checks if the string might be converted to positive integer. */
bool isNumber(const std::string& s) {
	return !s.empty() && std::all_of(s.begin(), s.end(), ::isdigit);
}

/* Checks validity of provided arguments. */
bool checkInputValidity(int argc, char* argv[]) {
	if (argc != 3) {
		std::cout << "Invalid number of arguments! Got: " << argc - 1 << ".\n";
		return false;
	}
	if (!isNumber(argv[1]) || std::stoi(argv[1]) < 1) {
		std::cout << "Thread number should be integer greater than 0! Got: " << argv[1] << ".\n";
		return false;
	}
	if (!isNumber(argv[2]) || std::stoi(argv[2]) < 2) {
		std::cout << "Matrix size should be 2 or greater! Got: " << argv[2] << ".\n";
		return false;
	}
	return true;
}

Matrix* generateMatrix(int matrix_size) {
	int* arr = new int[matrix_size * matrix_size];
	for (int i = 0; i < matrix_size * matrix_size; ++i) {
		arr[i] = rand() % 200 - 100;
	}
	return new Matrix(matrix_size, arr);
}

int main(int argc, char* argv[])
{
	// VALIDITY CHECK SECTION
	if (!checkInputValidity(argc, argv)) {
		return 0;
	}
	int thread_number = std::stoi(argv[1]);
	int matrix_size = std::stoi(argv[2]);

	// MATRIX GENERETION SECTION
	Matrix* matrix = generateMatrix(matrix_size);

	std::cout << "Input matrix is:\n";
	matrix->printMatrix();

	omp_set_num_threads(thread_number);

	CoordinateIterator iter(matrix_size);
	std::pair<int, int> pair;

#pragma omp parallel
	while ((pair = iter.getCoordinate()).first != -1) {
		getAlgebraicalComplement(*matrix, pair.first, pair.second);
	}
}
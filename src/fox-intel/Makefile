CXX = g++
CXXFLAGS = -std=c++17 -O3 -Wall
LIBS = -lcurl

all: findex fask

findex: findex.cpp json.hpp
	$(CXX) $(CXXFLAGS) findex.cpp -o findex $(LIBS)

fask: fask.cpp json.hpp
	$(CXX) $(CXXFLAGS) fask.cpp -o fask $(LIBS)

clean:
	rm -f findex fask

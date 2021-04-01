#!/usr/bin/env python3
from package.Classification import Classification

"""Machine Learning Implementation

This module will implement machine learning method base on
csv file in Dataset folder.
"""

__author__ = "Muhammad Ghazi Muharam"
__version__ = "0.1.0"
__license__ = "MIT"


def main():
    """ Main entry point of the app """
    model = Classification("../Dataset/data-0.4.csv")
    model.svm()
    model.GradientBoosting()
    model.KNeighbors(3)
    model.KNeighbors(5)
    model.KNeighbors(7)


if __name__ == "__main__":
    """ This is executed when run from the command line """
    main()

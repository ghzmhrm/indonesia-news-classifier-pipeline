#!/usr/bin/env python3
import pandas as pd
from sklearn.svm import SVC
from sklearn.ensemble import GradientBoostingClassifier
from sklearn.neighbors import KNeighborsClassifier
from sklearn.metrics import classification_report, confusion_matrix


class Classification():
    """
    This class does classification to provided dataset.
    """

    TEKNO_TRAIN_LENGTH = 6000
    FINANCE_TRAIN_LENGTH = 8000
    TEST_LENGTH = 2000

    def __init__(self, dataset: str) -> None:
        """
        Constructor.
        """
        self.dataset = pd.read_csv(dataset)
        self.X_train = None
        self.y_train = None
        self.X_test = None
        self.y_test = None
        self.dataset_builder()

    def dataset_builder(self):
        """
        This function does data split using 
        constant defined as class constant.
        """
        data_train = pd.concat([
            self.dataset[:self.TEKNO_TRAIN_LENGTH],
            self.dataset[self.TEKNO_TRAIN_LENGTH +
                         self.TEST_LENGTH:self.TEKNO_TRAIN_LENGTH +
                         self.TEST_LENGTH+self.FINANCE_TRAIN_LENGTH]
        ]).sample(frac=1)

        data_test = pd.concat([
            self.dataset[self.TEKNO_TRAIN_LENGTH:self.TEKNO_TRAIN_LENGTH +
                         self.TEST_LENGTH],
            self.dataset[self.TEKNO_TRAIN_LENGTH +
                         self.TEST_LENGTH+self.FINANCE_TRAIN_LENGTH:]
        ]).sample(frac=1)

        self.y_train = data_train['label']
        self.X_train = data_train.drop('label', axis=1)
        self.y_test = data_test['label']
        self.X_test = data_test.drop('label', axis=1)

    def svm(self):
        """
        This function does classification by using 
        Support Vector Classfier Algorythm.
        """
        model = SVC(gamma=1)
        model.fit(self.X_train, self.y_train)

        prediction = model.predict(self.X_test)
        print("Classification report for SVM\n\n",
              classification_report(self.y_test, prediction))
        print("Confusion matrix for SVM\n\n",
              confusion_matrix(self.y_test, prediction))

    def GradientBoosting(self):
        """
        This function does classification by using 
        Gradient Boosting Classfier Algorythm.
        """
        model = GradientBoostingClassifier(
            n_estimators=100, learning_rate=1.0,
            max_depth=1, random_state=0
        )
        model.fit(self.X_train, self.y_train)

        prediction = model.predict(self.X_test)
        print("Classification report for Gradient Boosting Classfier\n\n",
              classification_report(self.y_test, prediction))
        print("Confusion matrix for Gradient Boosting Classfier\n\n",
              confusion_matrix(self.y_test, prediction))

    def KNeighbors(self, k: int):
        """
        This function does classification by using 
        KNeighbors Classfier Algorythm.
        """
        model = KNeighborsClassifier(k)
        model.fit(self.X_train, self.y_train)

        prediction = model.predict(self.X_test)
        print(f"Classification report for KNeighbors Classfier {k} \n\n",
              classification_report(self.y_test, prediction))
        print(f"Confusion matrix for KNeighbors Classfier {k} \n\n",
              confusion_matrix(self.y_test, prediction))

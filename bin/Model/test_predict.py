from sklearn.metrics import classification_report, confusion_matrix
import pandas as pd
from sklearn.svm import SVC
from sklearn.ensemble import AdaBoostClassifier
from sklearn.neighbors import KNeighborsClassifier

df = pd.read_csv('./Dataset/data-0.4.csv')
df.head()

TEKNO_TRAIN_LENGTH = 6000
FINANCE_TRAIN_LENGTH = 8000
TEST_LENGTH = 2000

tekno_train = df[:TEKNO_TRAIN_LENGTH]
tekno_test = df[TEKNO_TRAIN_LENGTH:TEKNO_TRAIN_LENGTH+TEST_LENGTH]
finance_train = df[TEKNO_TRAIN_LENGTH +
                   TEST_LENGTH:TEKNO_TRAIN_LENGTH+TEST_LENGTH+FINANCE_TRAIN_LENGTH]
finance_test = df[TEKNO_TRAIN_LENGTH+TEST_LENGTH+FINANCE_TRAIN_LENGTH:]

train_data = pd.concat([tekno_train, finance_train]).sample(frac=1)
test_data = pd.concat([tekno_test, finance_test]).sample(frac=1)

del(tekno_train)
del(tekno_test)
del(finance_train)
del(finance_test)

X = train_data.drop('label', axis=1)
y = train_data['label']

clf = SVC(gamma=1)
clf.fit(X, y)

X = test_data.drop('label', axis=1)
y = test_data['label']

prediction = clf.predict(X)
print(classification_report(y, prediction))
print(confusion_matrix(y, prediction))

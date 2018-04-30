#!/bin/bash
# A script that sets up the django superuser and bootstraps the database

cd /var/www/waynetest/src/capstoneweb

echo "from django.contrib.auth.models import User; User.objects.filter(email='webappuser@waynetest.local').delete(); User.objects.create_superuser('webappuser', 'webappuser@waynetest.local', 'stoutcapstone')" | python3.6 /var/www/waynetest/src/capstoneweb/manage.py shell

echo "from polls.models import Question, Choice; from django.utils import timezone; q = Question(question_text='Are you excited for summer?', pub_date=timezone.now()); q.save(); q.choice_set.create(choice_text='Yes', votes=0); q.choice_set.create(choice_text='No', votes=0); q.choice_set.create(choice_text='SUN!', votes=0);" | python3.6 /var/www/waynetest/src/capstoneweb/manage.py shell

python3.6 manage.py migrate

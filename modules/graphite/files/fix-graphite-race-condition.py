import sys
sys.path.append('/opt/graphite/webapp')
from django.contrib.auth.models import User
from graphite.account.models import Profile
from graphite.logger import log
try:
  defaultUser = User.objects.get(username='default')
except User.DoesNotExist:
  randomPassword = User.objects.make_random_password(length=16)
  defaultUser = User.objects.create_user('default','default@localhost.localdomain',randomPassword)
  defaultUser.save()

try:
  defaultProfile = Profile.objects.get(user=defaultUser)
except Profile.DoesNotExist:
  defaultProfile = Profile(user=defaultUser)
  defaultProfile.save()


from django.contrib.auth import get_user_model
from rest_auth.registration.serializers import RegisterSerializer
from rest_auth.serializers import LoginSerializer
from rest_framework import serializers

# Get the UserModel
UserModel = get_user_model()


class CustomLoginSerializer(LoginSerializer):
    def __init__(self, *args, **kwargs):
        super(CustomLoginSerializer, self).__init__(*args, **kwargs)
        self.fields.pop('username')


class CustomRegisterSerializer(RegisterSerializer):
    name = serializers.CharField(
        max_length=255,
        required=False
    )

    def __init__(self, *args, **kwargs):
        super(CustomRegisterSerializer, self).__init__(*args, **kwargs)
        self.fields.pop('username')

    def get_cleaned_data(self):
        return {
            'password1': self.validated_data.get('password1', ''),
            'email': self.validated_data.get('email', ''),
            'name': self.validated_data.get('name', '')
        }


class CustomUserDetailsSerializer(serializers.ModelSerializer):
    """
    User model w/o password
    """

    class Meta:
        model = UserModel
        fields = ('pk', 'email', 'name')

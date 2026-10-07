<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class PasswordResetCodeNotification extends Notification
{
    use Queueable;

    public function __construct(public string $token) {}

    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        $expiresIn = config('auth.passwords.users.expire', 60);

        return (new MailMessage)
            ->subject('Your Quacko password reset code')
            ->greeting('Password reset requested')
            ->line('Use this code in the Quacko app to change your password:')
            ->line($this->token)
            ->line("This code expires in {$expiresIn} minutes. If you did not request this, you can ignore this email.");
    }
}

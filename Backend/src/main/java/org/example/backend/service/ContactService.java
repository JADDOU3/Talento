package org.example.backend.service;

import org.example.backend.Dto.ContactUsDto;
import org.example.backend.model.Parent;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class ContactService {

    @Autowired
    private JavaMailSender mailSender;

    @Value("${app.contact.recipient}")
    private String contactRecipient;

    public String sendContactMessage(ContactUsDto dto) {
        Parent parent = SecurityUtils.getCurrentUser();

        SimpleMailMessage mailMessage = new SimpleMailMessage();
        mailMessage.setTo(contactRecipient);
        mailMessage.setSubject(dto.getSubject());
        mailMessage.setText(
                "From: " + parent.getName() + " (" + parent.getEmail() + ")\n\n" + dto.getMessage()
        );
        mailMessage.setReplyTo(parent.getEmail());

        try {
            mailSender.send(mailMessage);
            return "Message sent successfully";
        } catch (Exception e) {
            return "Failed to send message";
        }
    }
}
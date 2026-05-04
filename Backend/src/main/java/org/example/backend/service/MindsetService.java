package org.example.backend.service;

import org.example.backend.Dto.mindset.CreateMindsetDto;
import org.example.backend.Dto.mindset.UpdateMindsetDto;
import org.example.backend.model.Mindset;
import org.example.backend.repo.MindsetRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class MindsetService {

    @Autowired
    private MindsetRepo mindsetRepo;

    public Mindset createMindset(CreateMindsetDto dto) {
        Mindset mindset = new Mindset();
        mindset.setName(dto.getName());
        mindset.setDescription(dto.getDescription());
        return mindsetRepo.save(mindset);
    }

    public List<Mindset> getAllMindsets() {
        return mindsetRepo.findAll();
    }

    public Mindset getMindsetById(int id) {
        return mindsetRepo.findById(id).orElse(null);
    }

    public Mindset updateMindset(int id, UpdateMindsetDto dto) {
        Mindset mindset = getMindsetById(id);
        if (mindset != null) {
            mindset.setName(dto.getName());
            mindset.setDescription(dto.getDescription());
            return mindsetRepo.save(mindset);
        }
        return null;
    }

    public void deleteMindset(int id) {
        mindsetRepo.deleteById(id);
    }
}

package org.example.backend.service;

import org.example.backend.Dto.ChildUpdateDto;
import org.example.backend.Dto.CreateChildDto;
import org.example.backend.model.Child;
import org.example.backend.model.User;
import org.example.backend.repo.ChildRepo;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class ChildService {

    @Autowired
    private ChildRepo childRepo;

    public Child createChild(CreateChildDto childDto){
        Child child = new Child();
        User user = SecurityUtils.getCurrentUser();
        child.setName(childDto.getName());
        child.setDateOfBirth(childDto.getDateOfBirth());
        child.setGender(childDto.getGender());
        child.setUser(user);
        child.setCreatedAt(LocalDateTime.now());

        if(childRepo.findByUserId(user.getId()).isEmpty()) {
            child.setSelected(true);
        } else {
            child.setSelected(false);
        }

        return childRepo.save(child);
    }

    public Child getChildById(int id){
            return childRepo.findById(id).orElse(null);
    }

    public List<Child> getAllChildrenByUser(int id){ return childRepo.findByUserId(id); }

    public  Child updateChild(ChildUpdateDto childUpdateDto){
        Child child = childRepo.findById(childUpdateDto.getId()).orElse(null);
        if(child == null)
            return null;
        User user = SecurityUtils.getCurrentUser();
        if(user.getId() != child.getUser().getId())
            return null;

        if(childUpdateDto.getName() != null) child.setName(childUpdateDto.getName());
        if(childUpdateDto.getDateOfBirth() != null) child.setDateOfBirth(childUpdateDto.getDateOfBirth());
        if(childUpdateDto.getGender() != null) child.setGender(childUpdateDto.getGender());

        return childRepo.save(child);

    }
    public String deleteChild(int id){
        User user = SecurityUtils.getCurrentUser();
        Child child = getChildById(id);
        if(child == null)
            return "Child not found";
        if(child.getUser().getId() != user.getId())
            return "You are not authorized to delete this child";
        childRepo.delete(child);
        return "Child deleted";
    }

    public Child getSelectedChild() {
        User user = SecurityUtils.getCurrentUser();
        Child selectedChild = childRepo.findByIsSelectedTrueAndUserId(user.getId());
        if(selectedChild == null) {
            return null;
        }

        return selectedChild;
    }

    @Transactional
    public Child selectChild(int id) {
        User user = SecurityUtils.getCurrentUser();
        Child child = getChildById(id);
        if(child.isSelected())
            return child;

        if (child == null || child.getUser().getId() != user.getId())
            return null;

        childRepo.deselectAllByUserId(user.getId());
        child.setSelected(true);
        return childRepo.save(child);
    }
}

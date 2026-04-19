package org.example.backend.service;

import org.example.backend.Dto.CreateChildDto;
import org.example.backend.model.Child;
import org.example.backend.model.User;
import org.example.backend.repo.ChildRepo;
import org.example.backend.util.SecurityUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

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

        return childRepo.save(child);
    }

    public Child getChildById(int id){
            return childRepo.findById(id).orElse(null);
    }

    public List<Child> getAllChildrenByUser(int id){ return childRepo.findByUserId(id); }

    public  Child updateChild(int id , Child NewChild){
        Child oldChild = getChildById(id);

        if(oldChild == null)
            return null;

        oldChild.setName(NewChild.getName());
        oldChild.setDateOfBirth(NewChild.getDateOfBirth());
        oldChild.setGender(NewChild.getGender());

        return childRepo.save(oldChild);

    }
    public void deleteChild(int id){
        User user = SecurityUtils.getCurrentUser();
        if(user.getChildren().stream().noneMatch(child -> child.getId() == id))
            return;
        Child removedChild = getChildById(id);
        childRepo.delete(removedChild);
    }
}

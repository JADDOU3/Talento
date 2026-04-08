package org.example.backend.service;

import org.example.backend.model.Child;
import org.example.backend.repo.ChildRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChildService {

    @Autowired
    private ChildRepo childRepo;

    public Child createChild(Child c){
        return childRepo.save(c);
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
        oldChild.setAge(NewChild.getAge());
        oldChild.setGender(NewChild.getGender());

        return childRepo.save(oldChild);

    }
    public void deleteChild(int id){
        Child removeChild = getChildById(id);
        childRepo.delete(removeChild);
    }
}

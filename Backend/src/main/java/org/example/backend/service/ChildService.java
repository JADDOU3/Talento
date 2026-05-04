<<<<<<< HEAD
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
=======
package org.example.backend.service;

import org.example.backend.Dto.child.ChildUpdateDto;
import org.example.backend.Dto.child.CreateChildDto;
import org.example.backend.model.Child;
import org.example.backend.model.Parent;
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
        Parent parent = SecurityUtils.getCurrentUser();
        child.setName(childDto.getName());
        child.setDateOfBirth(childDto.getDateOfBirth());
        child.setGender(childDto.getGender());
        child.setParent(parent);
        child.setCreatedAt(LocalDateTime.now());

        if(childRepo.findByParentId(parent.getId()).isEmpty()) {
            child.setSelected(true);
        } else {
            child.setSelected(false);
        }

        return childRepo.save(child);
    }

    public Child getChildById(int id){
            return childRepo.findById(id).orElse(null);
    }

    public List<Child> getAllChildrenByUser(int id){ return childRepo.findByParentId(id); }

    public  Child updateChild(ChildUpdateDto childUpdateDto){
        Child child = childRepo.findById(childUpdateDto.getId()).orElse(null);
        if(child == null)
            return null;
        Parent parent = SecurityUtils.getCurrentUser();
        if(parent.getId() != child.getParent().getId())
            return null;

        if(childUpdateDto.getName() != null) child.setName(childUpdateDto.getName());
        if(childUpdateDto.getDateOfBirth() != null) child.setDateOfBirth(childUpdateDto.getDateOfBirth());
        if(childUpdateDto.getGender() != null) child.setGender(childUpdateDto.getGender());

        return childRepo.save(child);

    }
    public String deleteChild(int id){
        Parent parent = SecurityUtils.getCurrentUser();
        Child child = getChildById(id);
        if(child == null)
            return "Child not found";
        if(child.getParent().getId() != parent.getId())
            return "You are not authorized to delete this child";
        childRepo.delete(child);
        return "Child deleted";
    }

    public Child getSelectedChild() {
        Parent parent = SecurityUtils.getCurrentUser();
        Child selectedChild = childRepo.findByIsSelectedTrueAndParentId(parent.getId());
        if(selectedChild == null) {
            return null;
        }

        return selectedChild;
    }

    @Transactional
    public Child selectChild(int id) {
        Parent parent = SecurityUtils.getCurrentUser();
        Child child = getChildById(id);
        if(child.isSelected())
            return child;

        if (child == null || child.getParent().getId() != parent.getId())
            return null;

        childRepo.deselectAllByParentId(parent.getId());
        child.setSelected(true);
        return childRepo.save(child);
    }
}
>>>>>>> 1fa9b86a49e02d460f12550142ed08adf9cf170e

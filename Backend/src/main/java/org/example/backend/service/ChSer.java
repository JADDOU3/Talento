package org.example.backend.service;

import org.example.backend.model.Child;
import org.example.backend.repo.ChRepo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChSer  {

    @Autowired
    private ChRepo chrepo;

    public Child createChild(Child c){
        return chrepo.save(c);
    }
    public Child getChildById(int id){
            return chrepo.findById(id).orElse(null);
    }
    public List<Child> getAllChildrenByParent(int id){
            return chrepo.findByParentId(id);
    }
    public  Child updateChild(int id , Child NewChild){
        Child oldChild = getChildById(id);
        if(oldChild == null)
            return null;
        oldChild.setName(NewChild.getName());
        oldChild.setAge(NewChild.getAge());
        oldChild.setGender(NewChild.getGender());

        return chrepo.save(oldChild);

    }
    public void deleteChild(int id){
        Child removeChild = getChildById(id);
        chrepo.delete(removeChild);
    }
}

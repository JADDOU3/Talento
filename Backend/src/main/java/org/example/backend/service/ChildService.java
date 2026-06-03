package org.example.backend.service;

import org.example.backend.Dto.child.ChildResponseDto;
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

    public ChildResponseDto createChild(CreateChildDto childDto) {
        return ChildResponseDto.from(createChildEntity(childDto));
    }

    private Child createChildEntity(CreateChildDto childDto) {
        Child child = new Child();
        Parent parent = SecurityUtils.getCurrentUser();
        child.setName(childDto.getName());
        child.setDateOfBirth(childDto.getDateOfBirth());
        child.setGender(childDto.getGender());
        child.setParent(parent);
        child.setCreatedAt(LocalDateTime.now());

        if (childRepo.findByParentId(parent.getId()).isEmpty()) {
            child.setSelected(true);
        } else {
            child.setSelected(false);
        }

        return childRepo.save(child);
    }

    public Child getChildById(int id) {
        return childRepo.findById(id).orElse(null);
    }

    @Transactional(readOnly = true)
    public ChildResponseDto getChildResponseById(int id) {
        return ChildResponseDto.from(getChildById(id));
    }

    @Transactional(readOnly = true)
    public List<ChildResponseDto> getAllChildrenByUser(int id) {
        return childRepo.findByParentId(id).stream().map(ChildResponseDto::from).toList();
    }

    public ChildResponseDto updateChild(ChildUpdateDto childUpdateDto) {
        return ChildResponseDto.from(updateChildEntity(childUpdateDto));
    }

    private Child updateChildEntity(ChildUpdateDto childUpdateDto) {
        Child child = childRepo.findById(childUpdateDto.getId()).orElse(null);
        if (child == null) return null;
        Parent parent = SecurityUtils.getCurrentUser();
        if (parent.getId() != child.getParent().getId()) return null;

        if (childUpdateDto.getName() != null) child.setName(childUpdateDto.getName());
        if (childUpdateDto.getDateOfBirth() != null) child.setDateOfBirth(childUpdateDto.getDateOfBirth());
        if (childUpdateDto.getGender() != null) child.setGender(childUpdateDto.getGender());

        return childRepo.save(child);
    }

    public String deleteChild(int id) {
        Parent parent = SecurityUtils.getCurrentUser();
        Child child = getChildById(id);
        if (child == null) return "Child not found";
        if (child.getParent().getId() != parent.getId()) return "You are not authorized to delete this child";
        childRepo.delete(child);
        return "Child deleted";
    }

    @Transactional(readOnly = true)
    public ChildResponseDto getSelectedChildResponse() {
        return ChildResponseDto.from(getSelectedChild());
    }

    public Child getSelectedChild() {
        Parent parent = SecurityUtils.getCurrentUser();
        return childRepo.findByIsSelectedTrueAndParentId(parent.getId());
    }

    @Transactional
    public ChildResponseDto selectChild(int id) {
        return ChildResponseDto.from(selectChildEntity(id));
    }

    private Child selectChildEntity(int id) {
        Parent parent = SecurityUtils.getCurrentUser();
        Child child = getChildById(id);
        if (child == null || child.getParent().getId() != parent.getId()) return null;
        if (child.isSelected()) return child;

        childRepo.deselectAllByParentId(parent.getId());
        child.setSelected(true);
        return childRepo.save(child);
    }
}

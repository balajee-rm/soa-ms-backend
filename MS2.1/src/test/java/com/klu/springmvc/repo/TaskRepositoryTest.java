package com.klu.springmvc.repo;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;

import com.klu.springmvc.model.Task;

@DataJpaTest
public class TaskRepositoryTest {
	@Autowired
    private TaskRepository taskRepository;

    @Test
    void testSaveAndFindTask() {
        Task task = new Task();
        task.setTitle("Test Task");
        task.setDescription("Integration test description");

        Task savedTask = taskRepository.save(task);

        assertThat(savedTask.getId()).isNotNull();
        assertThat(taskRepository.findById(savedTask.getId())).isPresent();
    }
}

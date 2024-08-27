//
//  StorageManager.swift
//  TaskListApp
//
//  Created by NikolayD on 27.08.2024.
//

import CoreData

final class StorageManager {
    
    static let shared = StorageManager()
    
    // MARK: - Core Data stack
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TaskListApp")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private lazy var context: NSManagedObjectContext = persistentContainer.viewContext
    
    private init() {}
    
    // MARK: - Core Data Saving support
    func saveContext () {
        do {
            try save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func fetchTaskList(completion: (Result<[ToDoTask], Error>) -> Void) {
        let fetchRequest = ToDoTask.fetchRequest()
        
        do {
            let taskList = try context.fetch(fetchRequest)
            completion(.success(taskList))
        } catch {
            completion(.failure(error))
        }
    }
    
    func saveTask(
        withName taskName: String,
        completion: (Result<ToDoTask, Error>) -> Void
    ) {
        let task = ToDoTask(context: context)
        task.title = taskName
        
        do {
            try save()
            completion(.success(task))
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteTask(
        _ task: ToDoTask,
        completion: (Result<ToDoTask, Error>) -> Void
    ) {
        context.delete(task)
        
        do {
            try save()
            completion(.success(task))
        } catch {
            completion(.failure(error))
        }
    }
    
    func updateTask(
        _ task: ToDoTask,
        withNewName newName: String,
        completion: (Result<ToDoTask, Error>) -> Void
    ) {
        task.title = newName
        
        do {
            try save()
            completion(.success(task))
        } catch {
            completion(.failure(error))
        }
    }
    
    private func save () throws {
        if context.hasChanges {
            try context.save()
        }
    }
}

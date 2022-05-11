//
//  ViewController.swift
//  TareasCoreData
//
//  Created by Mac11 on 10/05/22.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var listaTareas = [Tarea]()
    let contexto = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    @IBOutlet weak var tablaTareas: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tablaTareas.delegate=self
        tablaTareas.dataSource=self
        leer()
        // Do any additional setup after loading the view.
    }

    @IBAction func agregarTarea(_ sender: UIBarButtonItem) {
        //campo para el titulo
        var titulo = UITextField()
        let alerta = UIAlertController(title: "Agregar", message: "Tarea", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default) { (_) in
            //crear una nueva tarea
            
            let nuevaTarea = Tarea(context: self.contexto)
            nuevaTarea.titulo = titulo.text
            nuevaTarea.realizada = false
            
            
            //agregar esa tarea al arreglo de listaTareas
            
            self.listaTareas.append(nuevaTarea)
            
            
            self.guardar()
            
        }
        //agregar el textfied
        alerta.addTextField { (textFieldAlerta) in
            textFieldAlerta.placeholder="Escribe el titulo"
            titulo = textFieldAlerta
        }
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
    }
    
    func guardar() {
        
        do{
            try contexto.save()
        }catch{
            print("Error al guardar en core data: \(error.localizedDescription)")
        }
        
        self.tablaTareas.reloadData()
    }
    
    func leer(){
        let solicitud : NSFetchRequest<Tarea> = Tarea.fetchRequest()
        do{
            //asignar al arreglo de tareas la solicitud
            listaTareas = try contexto.fetch(solicitud)
        }catch{
            print("error al leer datos \(error.localizedDescription)")
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaTareas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tablaTareas.dequeueReusableCell(withIdentifier: "celda", for: indexPath)
        let tarea = listaTareas[indexPath.row]
        
        //operador ternario
        
        celda.textLabel?.text = tarea.titulo
        celda.textLabel?.textColor = tarea.realizada ? .black : .blue
        
        celda.detailTextLabel?.text = tarea.realizada ? "completada" : "Por completar ..."
        
        celda.accessoryType = tarea.realizada ? .checkmark : .none
        return celda
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tablaTareas.cellForRow(at: indexPath)?.accessoryType == .checkmark{
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .none
        }else{
            tablaTareas.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        //edicion
        
        listaTareas[indexPath.row].realizada = !listaTareas[indexPath.row].realizada
        guardar()
        
        
        
        tablaTareas.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let accionEliminar = UIContextualAction(style: .normal, title: "borrar") { (_, _, _) in
            self.contexto.delete(self.listaTareas[indexPath.row])
            self.listaTareas.remove(at: indexPath.row)
            self.guardar()
        }
        accionEliminar.image = UIImage(systemName: "trash")
        accionEliminar.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [accionEliminar])
    }
    
    
}

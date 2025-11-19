/* ===========================
   Trigger 2: asignarUsuarioAPrograma()
   - Solo permite usuarios con rol "Estudiante"
   - Verifica que el usuario y programa existan
   - Actualiza usuario.estudiante.programa_id
=========================== */
function asignarUsuarioAPrograma(usuarioId, programaId) {
    if (!usuarioId || !programaId) throw new Error("Se requieren usuarioId y programaId.");

    const uId = ObjectId(usuarioId);
    const pId = ObjectId(programaId);

    const usuario = db.usuarios.findOne({ _id: uId });
    if (!usuario) throw new Error("Usuario no encontrado.");
    if (!usuario.rol || usuario.rol.toLowerCase() !== "estudiante") {
        throw new Error("Solo los usuarios con rol 'Estudiante' pueden asignarse a un programa.");
    }

    const programa = db.programas.findOne({ _id: pId });
    if (!programa) throw new Error("Programa no encontrado.");

    db.usuarios.updateOne(
        { _id: uId },
        { $set: { "estudiante.programa_id": pId } }
    );

    print(`Usuario ${usuario.nombre} asignado al programa ${programa.nombre}`);
}

/* ===========================
   Trigger 3: registrarOrganizadorEvento()
   - Solo usuarios con rol "Docente" o "Estudiante"
   - Actualiza el documento de evento agregando campo 'Organizador'
=========================== */
function registrarOrganizadorEvento(eventoId, usuarioId) {
    if (!eventoId || !usuarioId) throw new Error("Se requieren eventoId y usuarioId.");

    const eId = ObjectId(eventoId);
    const uId = ObjectId(usuarioId);

    const usuario = db.usuarios.findOne({ _id: uId });
    if (!usuario) throw new Error("Usuario no encontrado.");

    const rol = (usuario.rol || "").toLowerCase();
    if (rol !== "docente" && rol !== "estudiante") {
        throw new Error("Solo Docente o Estudiante pueden ser organizadores.");
    }

    const evento = db.eventos.findOne({ _id: eId });
    if (!evento) throw new Error("Evento no encontrado.");

    const organizador = {
        usuario_id: uId,
        nombre: usuario.nombre + (usuario.apellido ? " " + usuario.apellido : ""),
        rol: usuario.rol
    };

    db.eventos.updateOne(
        { _id: eId },
        { $set: { Organizador: organizador } }
    );

    print(`Organizador ${usuario.nombre} registrado en evento ${evento.titulo}`);
}

/* ===========================
   Trigger 4: evaluarEvento()
   - Solo usuarios con rol 'Secretario'
   - Inserta registro en colección 'evaluacion'
   - Actualiza estado del evento
=========================== */
function evaluarEvento(eventoId, secretarioId, estado, justificacion) {
    if (!eventoId || !secretarioId || !estado) throw new Error("Se requieren eventoId, secretarioId y estado.");

    const eId = ObjectId(eventoId);
    const sId = ObjectId(secretarioId);

    const secretario = db.usuarios.findOne({ _id: sId });
    if (!secretario) throw new Error("Usuario evaluador no encontrado.");
    if (!secretario.rol || secretario.rol.toLowerCase() !== "secretario") {
        throw new Error("Solo usuarios con rol 'Secretario' pueden evaluar eventos.");
    }

    const evento = db.eventos.findOne({ _id: eId });
    if (!evento) throw new Error("Evento no encontrado.");

    // Insertar registro de evaluación
    const evaluación = {
        evento_id: eId,
        secretario_id: sId,
        estado: estado,
        justificacion: justificacion || null,
        fecha_evaluacion: new Date()
    };
    db.evaluacion.insertOne(evaluación);

    // Actualizar estado del evento
    db.eventos.updateOne(
        { _id: eId },
        { $set: { estado: estado } }
    );

    print(`Evaluación registrada: evento ${evento.titulo}, estado ${estado}`);
}

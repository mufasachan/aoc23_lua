local Queue = {}

function Queue.new()
	return {
		head = 1,
		tail = 1,
		elements = {}
	}
end

function Queue.is_empty(queue)
	return queue.head == queue.tail
end

function Queue.push(queue, element)
	-- print("LenA: :" .. Queue.len(queue))
	queue.elements[queue.tail] = element
	queue.tail = queue.tail + 1
	-- print("LenB: :" .. Queue.len(queue))
end

function Queue.pull(queue)
	local element = queue.elements[queue.head]
	queue.elements[queue.head] = nil
	queue.head = queue.head + 1

	return element
end

function Queue.delete(queue)
	queue.elements = nil
	queue.tail = nil
	queue.head = nil
	queue = nil
end

function Queue.len(queue)
	return queue.tail - queue.head
end

return Queue



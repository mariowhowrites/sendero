const Hooks = {
    mounted() {
        this.el.addEventListener("mousedown", e => {
            const target = e.target;
            const startX = e.clientX - target.offsetLeft;
            const startY = e.clientY - target.offsetTop;
            let newX;
            let newY;
            const onMouseMove = e => {
                newX = e.clientX - startX;
                newY = e.clientY - startY;

                target.style.left = `${newX}px`;
                target.style.top = `${newY}px`;
            };

            const onMouseUp = () => {
                document.removeEventListener("mousemove", onMouseMove);
                document.removeEventListener("mouseup", onMouseUp);

                this.pushEventTo(this.el, "drag_end", {left: newX, top: newY})
            };

            document.addEventListener("mousemove", onMouseMove);
            document.addEventListener("mouseup", onMouseUp);
        });
    }
}

export default Hooks